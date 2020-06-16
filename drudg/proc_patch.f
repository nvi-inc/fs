*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine proc_patch(icode,ifd)
      implicit none  !2020Jun15 JMGipson automatically inserted.

! Write out patch commands for Mk3/4 and for kk4
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'

      integer icode     ! Code
      integer ifd(*)            !<>0, this IF used.

! History:
! V1.00 2007Jul06.  First version. Separated from procs.f
! V1.01 2007Jul19.  Put in test for KSX
! 2015Jun05 JMG. Repalced squeezewrite by drudg_write.

! K41 and K42 rules fairly simple.

! Mark3/4 rules fairly complicated:

! First apply the geodesy rules :
!  0. If on IF3, always High.
!  1. If the upper edge of the recorded BandPass (which can possibly be
!     double sideband and is BW dependent) is below 230 MHz, pick low.
!  2. If the lower edge of the recorded BP is above 210, pick high.
!  3. For others if the center is of the recorded BP is below 220, pick
!     low, otherwise high.
!
!    For VC1, 2, 3, and 9, 10
!      apply these tests in order 1,2,3.
!    For VC4, 11, 12, 13, 14  and 5-8 if IF1 or IF2
!      apply them 2,1,3
!
! Then if the schedule is an 'astro' schedule apply the following:
!
!    I. Calculate all the patches according to geodesy rules.
!       A) If frequencies are X/S, use these and stop here;
!       B) for others go to step II.
!    II. For each LO:
!       A) If step (I) results in all high or low for an LO,
!    use that.
!       B) If for an LO step (I) results in mixed patching, check which
!       patch is more common, high or low, then apply one of IIa, IIb,
!        or IIc:
!    IIa. If high is more common, check low patches, for any channels
!    (considering both sidebands if both are recorded) where the lower
!    edge is above 210, change those VCs to high.
!    IIb. If low is more common, check high patches, for any channels
!    considering both sidebands if both are record) where the upper edge
!    is below 230, change those VCs to low.
!    IIc. If equal high and low, try IIa and IIb, choose the one that
!    makes the most patches the same. If still equal, pick IIa.


! functions
      integer mcoma
      integer trimlen
! local
      logical ksx              ! KSX schedule?

      integer ib                !ibbc#
      integer ic                !channel index
      integer iv                !channel#
      integer ioff
      integer ibov4             ! which set of 4 BBCs are we in (for K41)
      integer i,j               ! loop counters
      integer nch               ! number of characters
      integer nch2

      integer igotbbc(max_bbc)  !<>0, then are using this bbc.

! These arrays below hold trial patching.
! In the case of geodetic schedules,  we use  ipatch_test for the patching.
! In the case of astrometric schedules, we try various alternatives trying to
! maximum the number which are the same for each LO.

      integer ipatch_test(max_bbc)     !Patching test
      integer ipatch_test_alt(max_bbc) !patching test_lo
      integer num_hi,num_lo            !number which were patched high & lo
      integer num_hi_alt,num_lo_alt

      character*4 l1234
      character*1 l_LH(2)

      character*5 ck41_bbc(4)
!      integer ick41_bbc_len(4)
      character*2 ck42_bbc(16)
      real fr


      data l_LH/"l","h"/
      data ck41_bbc/"1-4","5-8","9-12","13-16"/
!      data ick41_bbc_len/3,3,4,5/

      data ck42_bbc/'a1','a2','a3','a4','a5','a6','a7','a8',
     >              'b1','b2','b3','b4','b5','b6','b7','b8'/

      data l1234/"1234"/

! Check to see if ksx.
      ksx=.true.
! check to see if there is sky frequency which is out of bounds. If so, then not ksx
      if (kmracks) then ! mk3/4/5
        do ic=1, nchan(istn,icode)
          fr = FREQRF(ic,istn,ICODE) ! sky freq
          j=index(l1234,cifinp(ic,istn,icode)(1:1))
          if(j .eq. 1) then
            if(abs(fr) .gt. 0) then
               if( .not.(fr .ge. 8000.d0 .and. fr .le. 9000.d0)) then
                 ksx=.false.
               endif
            endif
          else if(j .eq. 2) then
            if(abs(fr) .gt. 0) then
               if( .not.(fr .ge. 2000.d0 .and. fr .le. 3000.d0)) then
                 ksx=.false.
               endif
            endif
          endif
        end do
      endif

      do i=1,max_bbc
        igotbbc(i)=0
      enddo
      write(lu_outfile,'(a)') "patch="

      DO I=1,3 ! up to three Mk3/4, K4 IFs need a patch command
        if (ifd(i) .gt. 0) then ! this LO in use

          cbuf="patch=lo"//l1234(i:i)             !e.g, patch=lo2
          nch=10
          if(i .le. 2) then                       ! For LOs 1 & 2, don't know patching until the end.
            do j=1,max_bbc                        ! These contain various trial patching.
               ipatch_test(j)=0
            end do
          end if

          DO ic = 1,nchan(istn,icode)
            iv=invcx(ic,istn,icode) ! channel number
            ib=ibbcx(iv,istn,icode) ! VC number
            if (igotbbc(ib).eq.0) then! do this BBC
              j=index(l1234,cifinp(ic,istn,icode)(1:1))
              if(j .eq. i) then
                igotbbc(ib)=1
                if(i.eq. 3 .or. kk41rack .or. kk42rack)      !in these cases, always write out patching as we go along
     >              NCH = MCOMA(IBUF,NCH)
                if (kmracks) then ! mk3/4/5
                  if (i.eq.3) then !IF3 always high
                    write(cbuf(nch:nch+3),'(i2,"h")') ib
                    nch=nch+3
                  else  ! IF1 and IF2 may be high or low
                     if((ib.ge.1 .and. ib.le.3) .or.
     >                  ib.eq.9 .or. ib.eq. 10) then
                      if(fvc_hi(ib) .lt. 230.0) then
                        ipatch_test(ib)=1                   !LO
                      else if(fvc_lo(ib) .gt. 210.0) then
                        ipatch_test(ib)=2                   !HI
                      else if((fvc_lo(ib)+fvc_hi(ib))/2. .lt. 220.0)then
                        ipatch_test(ib)=1                   !LO
                      else
                        ipatch_test(ib)=2                   !HI
                      endif
                    else
                      if(fvc_lo(ib) .gt. 210.0) then
                        ipatch_test(ib)=2                   !HI
                      else if(fvc_hi(ib) .lt. 230.0) then
                       ipatch_test(ib)=1                    !LO
                      elseif((fvc_lo(ib)+fvc_hi(ib))/2. .lt. 220.0)then
                       ipatch_test(ib)=1                    !LO
                      else
                        ipatch_test(ib)=2                   !HI
                      endif
                    endif
                  endif
                else if(kk41rack) then ! k4
!K41 racks BBCs come in packs of 4.
! Find which set of 4.
                  ibov4=(ib-1)/4
                  ioff=ibov4*4
! Indicate all used
                  do j=1,4
                    igotbbc(ioff+j)=1
                  end  do
                  nch2=trimlen(ck41_bbc(ibov4+1))
                  cbuf(nch:nch+nch2-1)=ck41_bbc(ibov4+1)   ! e.g.,  '1-4'
                  nch=nch+nch2
                else if(kk42rack) then
                  cbuf(nch:nch+1)=ck42_bbc(ib)        ! e.g., 'a1' etc.
                  nch=nch+2
                endif ! Kind of rack.
              endif ! correct LO
            endif ! do this BBC
          ENDDO   ! End of loop over LO
! Construct the output string if we need to.
          if(i.eq. 3 .or. kk41rack .or. kk42rack) then
            continue         !already done.
          else
! This part of the code finds the optimum patching.
            if(kgeo .or. ksx) then
! We should be satisfied with the above patching.
              continue
            else        ! non-SX Astro.
! Try various schemes to have the most patching.
              num_lo=0
              num_hi=0
! First, count how many are high or low.
              do ib=1,max_bbc
                if(ipatch_test(ib) .eq.  1) then
                  num_lo=num_lo+1
                else if(ipatch_test(ib) .eq. 2) then
                  num_hi=num_hi+1
                endif
              end do
              if(num_hi .eq. 0 .or. num_lo .eq. 0) then
                 continue                        	!Case 1. All high or low. We are done.
              else if(num_hi .gt. num_lo) then   	!Case 2. More high than low. See if we can make even more high.
                do ib=1,max_bbc
                  if(ipatch_test(ib) .eq. 1 .and. fvc_lo(ib) .gt.210.d0)
     >               ipatch_test(ib)=2
                end do
              else if(num_lo .gt. num_hi) then 		!Case 3. More lo than high. See if we can even more low.
                do ib=1,max_bbc
                  if(ipatch_test(ib) .eq. 2 .and. fvc_hi(ib) .lt.230.d0)
     >               ipatch_test(ib)=1
                end do
              else if(num_hi .eq. num_lo) then
!Case 4. Try two alternatives, and pick the one that gives the most the same.
!  Default case is try to make most patches high starting with original patching.
!  Alternative tries to make most patches low starting with original patching.
                num_lo_alt=num_lo                  !Alternative case starts with original patching
                num_hi_alt=num_hi                  !
                do ib=1,max_bbc
! See what happens if we can change to high the onese we can.
                  ipatch_test_alt(ib)=ipatch_test(ib)  !Copy alternative to original patching.
                  if(ipatch_test(ib).eq.1) then
                    if(fvc_lo(ib) .gt. 210.d0) then !See if we can make high in original.
                      ipatch_test(ib)=2
                      num_hi=num_hi+1
                      num_lo=num_lo-1
                    endif
                  else if(ipatch_test_alt(ib) .eq. 2) then
                    if(fvc_hi(ib).lt. 230.d0) then  !See if we can make low in alternative.
                      ipatch_test_alt(ib)=1
                      num_hi_alt=num_hi_alt-1
                      num_lo_alt=num_lo_alt+1
                    endif
                  endif
                end do

                if(num_lo_alt .gt. num_hi) then    !If we had more lows thans, use this patching.
                  do ib=1,max_bbc
                    ipatch_test(ib)=ipatch_test_alt(ib)
                  end do
                endif
              endif
            endif
! Optimimum patching found. Construct output string.
            do ib=1,max_bbc
               if(ipatch_test(ib) .ne. 0) then          !Is used.
                  write(cbuf(nch:nch+4),'(",",i2,a)') ib,
     >               l_lh(ipatch_test(ib))
                  nch=nch+4
                endif
            end do
          endif
          call drudg_write(lu_outfile,cbuf)
        endif ! this LO in use
      ENDDO ! three Mk3/4 IFs need a patch command
      return
      end

