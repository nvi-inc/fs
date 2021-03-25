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
      SUBROUTINE count_freq_tracks(cbnd,nbnd,luscn)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'

! History
!  V1.00  2004Sep22, first version.
!  V1.01  2004Oct04, modified to include effect of fanout.
!  2006Jun22  JMGipson.  Modified to assume we only use freqrf>0.
!  2006Oct06  Assume cbarrel=" " is valid.
!  2008Jun10  Wasn't counting tracks if recorder was S2?
! 2013Sep19  JMGipson made sample rate station dependent
! 2016Dec05 JMGipson. Error in setting the sample rate. Used first stations VC BW. Now uses stations BW.
! 2021-01-31 JMG Don't check barrel roll 
! 2021-03-05 Issue warning here if mode not defined for a station. Prevously done in itras. 

! functions
      integer itras
      integer itras_map
      integer iwhere_in_string_list

! passed
      character*2 cbnd(2)
      integer nbnd
      integer luscn
C
C  LOCAL VARIABLES
      integer ierr,ip,ic,i,iv,is,isub,iul
      integer ih
      character*3 cs
C
C  1. Count number of frequencies and the number of tracks being
C     recorded at each station on each frequency.
C
      ierr=0
      nbnd=0

      cbnd(1)=" "
      cbnd(2)=" "
      do ic=1,ncodes
         do is=1,nstatn
! Quick check to see if the mode is defined for this station. 
          if(itras_map(is,ic) .eq. 0) then
            write(*,*) "Track map not defined for station ",cstnna(is),
     >        " and mode ", cnafrq(ic)
             goto 100
          endif 

          nfreq(1,is,ic)=0
          nfreq(2,is,ic)=0
          do i=1,nchan(is,ic)
            iv=invcx(i,is,ic)
            if (iv.ne.0 ) then ! this channel is used
              isub=iwhere_in_string_list(cbnd,nbnd,csubvc(iv,is,ic))
              if(isub .eq. 0) then
                nbnd=nbnd+1
                if(nbnd .ge. 3) then
                  write(luscn,*) "Count_freq_tracks:  Too many bands. ",
     >               ccode(ic), "ignored."
                  nbnd=nbnd-1
                  return
                endif
                cbnd(nbnd)=csubvc(iv,is,ic)
                isub=nbnd
              endif
              nfreq(isub,is,ic)=nfreq(isub,is,ic)+1 !count number of frequencies
              cs=cset(iv,is,ic)
!              if(freqrf(iv,is,ic).gt.0 .and.
!     >            cstrec(is,1)(1:2).ne."S2") then
               if(freqrf(iv,is,ic).gt.0) then
                do iul=1,2
                  ip=1
C               Full addition for sign bit
                  do ih=1,max_headstack
                    if (itras(iul,1,ih,iv,ip,is,ic).ne.-99) then
                      if (cs.eq.'1,2'.or.cs(1:1).eq.' ') then ! both cycles
C                        All the data on un-switched tracks are used
                         trkn(isub,is,ic)=trkn(isub,is,ic)+1
                         ntrkn(isub,is,ic)=ntrkn(isub,is,ic)+1
                      else if (cs(1:1).eq.'1') then ! one cycle=switched
C                        Two-thirds of the data on a switched track are used
                         trkn(isub,is,ic)=trkn(isub,is,ic)+0.6667
                         ntrkn(isub,is,ic)=ntrkn(isub,is,ic)+1
                      endif
                    endif
!C                 Add another 0.978 for magnitude bit
! This is wrong! Contribution of magnitude bit is ~ 0.2411 sign
! Quick derivation:
! 1-bit efficiency is 0.571429
! 2-bit efficiency is 0.63662
! (2-bit)/(1-bit) = 0.63622/0.571529=sqrt(1.241184)

                    if (itras(iul,2,ih,iv,ip,is,ic).ne.-99) then
                      trkn(isub,is,ic) =trkn(isub,is,ic)+0.978
!                       trkn(isub,is,ic) =trkn(isub,is,ic)+0.24118
                      ntrkn(isub,is,ic)=ntrkn(isub,is,ic)+1
                    endif
                  enddo
                end do
              endif
            endif
          enddo
! Issue warning.
!          itrk_tot=(ntrkn(1,is,ic)+ntrkn(2,is,ic))*ifan(is,ic)
100   continue  
         enddo
      enddo
C  1.5 Calculate sample rate if not specified.

C
      do is=1,nstatn
        do ic=1,ncodes
          if (samprate(is,ic).eq.0) samprate(is,ic)=2.0*vcband(is,1,ic)
        enddo
      end do

      RETURN
      END

