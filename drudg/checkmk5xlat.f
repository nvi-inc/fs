      subroutine CheckMk5xlat(itrk,ifan_fact,num_chans_obs,
     >itrack_off,ierr)
!     Check to see if we can translate Mk5 tracks simply.
      include '../skdrincl/skparm.ftni'

! function
      integer num_tracks_in_range

! passed
      integer itrk(max_track,max_headstack)
      integer ifan_fact
      integer num_chans_obs
      integer itrack_off
      integer ierr

! local
      integer num_tracks
      integer num_tracks_found
      integer ihead,ipass

      integer ibeg(8),iend(8),ioff(8)
      integer ib,ie

      data ibeg/2,10,18,26,3,11,19,27/
      data iend/8,16,24,32,9,17,25,33/
      data ioff/0,-8,-16,-24,-1,-9,-17,-25/

      num_tracks=ifan_fact*num_chans_obs
      ierr=0

      if(num_tracks .lt.4) then
        ierr=1
        return
      endif

! see if the tracks set are some valid subset.
! if so, find offset to translate back to track2.

      if(num_tracks .eq. 4) then
        ihead=1
        do ipass=1,8
          ib=ipass
          ie=ipass
          num_tracks_found=num_tracks_in_range(itrk,
     >      ibeg(ib),iend(ie),ihead)
          if(num_tracks_found .eq. num_tracks) then
            itrack_off=ioff(ib)
            return
          else if(num_tracks_found .eq. 0) then
            continue
          else
            ierr=-1
            return
          endif
        end do
      else if(num_tracks .le. 8) then
        ihead=1
        do ipass=1,4
          ib=(ipass-1)*2+1
          ie=ipass*2
          num_tracks_found=num_tracks_in_range(itrk,
     >      ibeg(ib),iend(ie),ihead)
          if(num_tracks_found .eq. num_tracks) then
            itrack_off=ioff(ib)
            return
          else if(num_tracks_found .eq. 0) then
            continue
          else
            ierr=-1
            return
          endif
        end do
      else if(num_tracks .le. 16) then
        ihead=1
        do ipass=1,2
          ib=(ipass-1)*4+1
          ie=ipass*4
          num_tracks_found=num_tracks_in_range(itrk,
     >      ibeg(ib),iend(ie),ihead)
          if(num_tracks_found .eq. num_tracks) then
            itrack_off=ioff(ib)
            return
          else if(num_tracks_found .eq. 0) then
            continue
          else
            ierr=-1
            return
          endif
        end do
      else if(num_tracks .le. 32) then
        itrack_off=0
      else if(num_tracks .le. 64) then
        itrack_off=0
      endif
      return
      end
!**********************************************************************
      integer function num_tracks_in_range(itrk,ibeg,iend,ihead)
! find number of tracks in range. Note that we do by even increments.
      include '../skdrincl/skparm.ftni'
      integer itrk(max_track,max_headstack)
      integer ibeg,iend,ihead
! local
      integer i

      num_tracks_in_range=0
      do i=ibeg,iend,2
        if(itrk(i,ihead) .ne. 0) then
            num_tracks_in_range=num_tracks_in_range+1
        endif
      end do
      return
      end















