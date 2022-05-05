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
      subroutine proc_trkf(icode,lwhich8,ierr)
! Write TRKF and RECP procedures
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'

! passed
      integer icode     
      character*1 lwhich8               !flag for (F)irst 8 BBCs or (L)ast

! returned
      integer ierr      !error

!functions
      integer itras     !returns track#, or -1 if not set.
      integer iaddtr    !write another track to cbuf    


! History
! 2007Jul11 Split off from procs.f
! 2009Sep08 Fixed bug in filling up extra tracks if used 2nd headstack
! 2014Dec10 JMG. Modified test to switch tracks to only work when in non-VEX mode. 

! local
      character*12 cnamep               !function name
      character*4 cpmode                !mode name    

      integer im5chn_dup                !number of duplicated channels.
      integer num_chans_obs         	!number of channels observer
      integer num_tracks_rec_mk5        !number we record=num obs * ifan
      integer ifan_fact                 !identical to ifan(,) unless ifan(,)=0, in which case this is 1.
      integer itemp                     !Short lived variable.
      integer itrackoff                 !offset for Mark5 tracks
      integer numtracks
      integer MaxTrack
      parameter (MaxTrack=35)
      integer itrackvec(MaxTrack,2)     !used to keep track of assigned tracks.
      integer i,j                       !loop counter

      logical kinclude                  !include it?

      integer ichan                     !channel counter
      integer ic                        !channel #
      integer ib                        !bbc #
      integer it                        !track #
      integer ihead                     !head
      integer ihdtmp
      integer isb                       !sideband
      integer ibit                      !bit counter

!                               The following are used if the sky-frequency is negative.
!                               Initialized with last good combination.
      integer isb_good                  !A "good"sideband
      integer ib_good                   !A "good" BBC#

      integer isb_out                  !
      integer ib_out                   !
      integer it_out                   !

!                             Used for Piggyback.
      integer itvec(130)               ! Keep track of tracks, BBC, SB, ibit
      integer ibvec(130)               ! while writing out on headstack 1, and
      integer isbvec(130)              ! then write out on headstack two
      integer ibitvec(130)


      integer ir                        !recorder. Default is first.
      integer nch                       !string character counter
      integer iptr                      !pointer into an array

      character*1 cvpass(28)
      character*28 cvpassTmp
      equivalence (cvpass,cvpassTmp)
  

      integer ipass                     ! pass counter

      data CvpassTmp /'abcdefghijklmnopqrstuvwxyzab'/

      ir = 1
      if (kuse(2).and..not.kuse(1)) ir = 2
      
      ipass=1
      call trkall(ipass,istn,icode,
     >    cmode(istn,icode), itrk,cpmode,ifan(istn,icode))

      if(KM5APigWire(ir) .or. KM5A_Piggy .or.KM5Arec(ir)) then
          ifan_fact=max(1,ifan(istn,icode))
          call find_num_chans_rec(ipass,istn,icode,
     >            ifan_fact, num_chans_obs,num_tracks_rec_mk5)
          call CheckMk5xlat(itrk,ifan_fact,num_chans_obs,itrackoff,ierr)
          if(ierr .ne. 0) then
            write(luscn,'(/a)')
     >       "***** Proc_trkf error: Can't do Mk5 track assignments."
            write(luscn,'(a)')
     >         "***** Tracks don't all fit within one pass."
              return
           endif
          im5chn_dup=num_tracks_rec_mk5/ifan_fact-num_chans_obs       !This is the number of channels to duplicate
      endif
      
      cnamep="trkf"//ccode(icode)
       
      call proc_write_define(lu_outfile,luscn,cnamep)

      cbuf="trackform="
      nch=11       
      write(lu_outfile,'(a)') cbuf(1:nch)

! This is used below for handling Mark5A and Mark5P
      numtracks=0
      itemp=0
      call ifill4(ItrackVec,MaxTrack,itemp)
      call ifill4(itrackvec(1,2),MaxTrack,itemp)
! Assign tracks for all non-piggyback modes. Piggyback handled separately.
      ib=0
      ib_good=0
      DO ichan=1,nchan(istn,icode) !loop on channels
         ic=invcx(ichan,istn,icode) !channel number
         do ihead =1,max_headstack  !2hd hedzz
           do isb=1,2 ! sidebands
             do ibit=1,2 ! bits
               if(nch .eq. 0) then    !initialize front of line.                
                 cbuf="trackform="
                 nch=11                
                 ib=0
               endif
               it=itras(isb,ibit,ihead,ic,ipass,istn,icode) 
          
               kinclude=.false.
               if (it.ne.-99) then ! assigned
C             Use BBC number, not channel number
                 ib=ibbcx(ic,istn,icode) ! BBC number
                 kinclude=.true.
                 if(k8bbc) then
                   call proc_check8bbc(km3be,km3ac,lwhich8,ichan,
     >               ib,kinclude)
                 endif
               endif

! track is assigned, and we want to include in track assigntments. do so.
               if(kinclude) then
                 isb_out=isb
                 if(abs(freqrf(ic,istn,icode)).lt.
     >                freqlo(ic,istn,icode)) then 
                    isb_out=3-isb    !swap the sidebands
                 endif ! reverse sidebands
                 if(.true.) then    
                    if(km5APigWire(ir)) then
                      if(km4form) then
                        ihdtmp=2    !put out on 2nd headstack.
                      else
                       ihdtmp=1
                      endif
                    else
                      ihdtmp=ihead
                    endif

                    if(KM5APigWire(ir).or.KM5Arec(ir)) it=it+itrackoff
                    if(freqrf(ic,istn,icode) .lt.0) then  !Bad sky frequency.
                       ib_out    =ib_good           !replace bbc, sideband and bit with last good value.
                       isb_out   =isb_good
                    else
                      if(ib_good .eq. 0) then !first time we have a good value.
!                        Use these values for the previous NumTracks times (which were bad.)
                        cbuf="trackform="
                        nch=11
                        do j=1,NumTracks
                          it_out=itvec(j)
                          if(ihdtmp .eq. 2) it_out=it_out+100
                          nch=iaddtr(ibuf,nch,it_out,ib,isb_out,ibit)      !first headstack
                          ibvec(j)=ib
                          isbvec(j)=isb_out
                          ibitvec(j)=ibit
                        end do
                      endif
                      ib_good=ib
                      isb_good=isb_out
                   endif

                   it_out=it
                   ib_out=ib_good

                   if(ihdtmp .eq. 2) it_out=it_out+100
                   if(ib_out.gt. 0) then                 !write out only if have good BBC
                     nch=iaddtr(ibuf,nch,it_out,ib_out,isb_out,ibit)
                   endif

                   NumTracks=NumTracks+1      !used latter in piggyback mode.
                   itrackvec(it,ihdtmp)=1
                   itvec(Numtracks)=it
                   ibvec(Numtracks)=ib
                   isbvec(Numtracks)=isb_out
                   ibitvec(NumTracks)=ibit 
                 endif
                 ib=1
               endif  !include
                if (kinclude.and.ib.ne.0.and.nch.gt.60) then ! write a line
                 call delete_comma_and_write(lu_outfile,ibuf,nch)
               endif
             enddo ! bits
           enddo ! sidebands
         enddo !2hd loop on hedzz
       enddo ! loop on channels

       if (nch.ne.11.and.nch .ne. 0) then
          call delete_comma_and_write(lu_outfile,ibuf,nch)
       endif
! **** Start of Special Mark5 stuff

! Take care of easy part of piggy back.
        if(KM5P_piggy .and. km4form) then  !mapped to 2nd headstack for Mark4form
          do i=1,Numtracks                 !don't need to do anything for VLBAform
            if(nch .eq.0) then
               cbuf="trackform="
               nch=11
            endif
            nch = iaddtr(ibuf,nch,itvec(i)+100,
     >               ibvec(i),isbvec(i),ibitvec(i))
            if (nch.gt.60) then ! write a line
              call delete_comma_and_write(lu_outfile,ibuf,nch)
            endif
          end do
        else if(KM5A_piggy) then
          do i=1,Numtracks
            if(nch .eq.0) then
              cbuf="trackform="
              nch=11
            endif
            it=itvec(i)+itrackoff        !itrackoff moves tracks to the beginning.

            if(km4form) then
              ihdtmp=2
            else
              ihdtmp=1
            endif

            if(itrackvec(it,ihdtmp) .eq. 0) then     !make sure not used
              itrackvec(it,ihdtmp)=1
              it=it+(ihdtmp-1)*100
              nch = iaddtr(ibuf,nch,it,ibvec(i),isbvec(i),ibitvec(i))
            endif

            if (nch.gt.60) then ! write a line
              call delete_comma_and_write(lu_outfile,ibuf,nch)
            endif
          end do
        endif
        if (nch.ne.11.and.nch .ne. 0) then ! final line
          call delete_comma_and_write(lu_outfile,ibuf,nch)
        endif

        if(KM5Prec(ir).or. KM5P_Piggy) then      !we may need to duplicate some tracks.
          if(Km5P_piggy.and.km4form) then
            ihead=2
          else
            ihead=1
          endif
          do i=1,NumTracks
            if(nch .eq.0) then
              cbuf="trackform="
              nch=11
            endif
            it=itvec(i)
            if(mod(it,2) .eq. 0) then               !even
              if(itrackvec(it+1,ihead) .eq. 0) then     !next odd is free. Duplicate track
                it=it+1
              else
                it=0
              endif
            else       !below is for odd tracks. Start at 3.
              if(itrackvec(it-1,ihead) .eq. 0) then    !previous even is free. Duplicate track.
                it=it-1
              else
                it=0
              endif
            endif
            if(it .ne. 0) then
              nch = iaddtr(ibuf,nch,it+(ihead-1)*100,ibvec(i),
     >                     isbvec(i), ibitvec(i))
              itrackvec(it,ihead)=1
            endif
            if(nch .gt. 60) then  !write last line.
              call delete_comma_and_write(lu_outfile,ibuf,nch)
            endif
          end do
        endif   !KM5Prec

! For Mark5A, Mark5A_Piggy, and Mark5A_PigWire, we need to fill up to 8, 16, or 32.
! now need to make sure we do number of duplicates, starting with even.
        if(KM5Arec(ir) .or. KM5A_piggy .or. KM5APigWire(ir)) then
          iptr=2   !point to first possible free spot.
          i=1
          ihead=1
          if((KM5A_piggy.or.KM5APigWire(ir)).and.km4form) ihead=2
          do while(im5chn_dup .gt. 0)
            if(nch .eq.0) then
              cbuf="trackform="
              nch=11
            endif
            im5chn_dup =im5chn_dup-1
! find a free spot in the track assignment table.
! Start with 2 on head 1. If can't find even, go to odds. If can't find odds, go to head 2.
            if(iptr .eq. 33) then
               ihead=ihead+1
               iptr=2
            endif
            do while(ihead .le. 2 .and. iptr .le. 32 .and.
     >        itrackvec(iptr,ihead) .eq. 1)
              do while(iptr.le.32.and.itrackvec(iptr,ihead).eq.1)
               iptr=iptr+2*ifan_fact
              end do
              if(iptr.gt.32 .and. mod(iptr,2).eq.0) then !didn't find a free even spot.
                iptr=3                                   !try odd
                do while(iptr.le.33.and.itrackvec(iptr,ihead).eq.1)
                  iptr=iptr+2*ifan_fact
                end do
              endif
            end do

            if(iptr .le. 33 .and. ihead .le. 2 .and.   !found unused track!
     >         itrackvec(iptr,ihead) .eq. 0) then
               itrackvec(iptr,ihead)=1
               it=iptr
               if(km4form.and.
     >           (KM5A_piggy.or.KM5APigWire(ir).or.ihead.eq.2)) then
                 it=it+100   !for Mark4 formatters, write out on 2nd headstack.
               endif
               nch = iaddtr(ibuf,nch,it,ibvec(i),isbvec(i),ibitvec(i))
            endif
            i=i+1                   !point to next one to output.
! write out line if necessary.
            if (nch.gt.60) then ! write a line
               call delete_comma_and_write(lu_outfile,ibuf,nch)
             endif
            end do
          endif
          if(nch .ne. 11 .and. nch .ne. 0) then  !write last line.
            call delete_comma_and_write(lu_outfile,ibuf,nch)
          endif
! ***** End of special Mark5 Stuff.
       write(lu_outfile,"(a)") 'enddef'
    

      return
      end

