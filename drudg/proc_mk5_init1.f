      subroutine proc_mk5_init1(ntrack_obs,ntrack_rec_mk5,luscn,ierr)
      implicit none
      include 'hardware.ftni'
! passed
      integer ntrack_obs       !number of tracks we normally record on
      integer ntrack_rec_mk5   !number we actually used  in mk5 (must be 8,16,32 or 64
      integer luscn            !LU to output error messages (normally the screen).
! returned
      integer ierr             !some error
! local
      character*6 lmark5

      ierr=0
      if(km5a_piggy .and. ntrack_rec_mk5 .gt. 32 .or.
     >   km5p_piggy .and. ntrack_rec_mk5 .gt. 32) then
         write(luscn,'(/,a)')
     >      "PROC_MK5_INIT1: Can't piggyback with more than 32 tracks!"
        ierr=101
        return
      endif


! Put some instructions out for MK5 recorders.
      if(km5p .or. km5p_piggy .or. km5A_piggy) then
! Output instructions for the recorders. These are common both piggyback and Mark5P mode.
        if(km4form) then
           write(lufile,90)"Connect the tape recorder to the "
           write(lufile,90)"headstack 1 output of the formatter."
         else if(kvrack) then
           write(lufile,90)"Connect the tape recorder to the "
           write(lufile,90)"first recorder output of the formatter."
         endif
         if(km5a_piggy) then
            lmark5="Mark5A"
         else
            lmark5="Mark5P"
         endif
         if(km4form) then
           if(km5P_piggy) then
             write(lufile,90)"Connect the Mark5P recorder to the"
           else
             write(lufile,90)"Connect the Set 1 Mark 5A recorder input"
           endif
           write(lufile,90)"to the headstack 2 output of the formatter."
         else if(kvrack) then
           write(lufile,90)"Connect the "//lmark5//" recorder to the"
           write(lufile,90)"second recorder output of the formatter."
         endif
      else if(km5) then
! setup for number of tracks observed and recorded.
        if(ntrack_obs .lt. 4) then
           write(luscn,'(/,a)')
     >       "PROC_MK5_INIT1: Too few tracks in Mk5 mode!"
           write(luscn,*) "Minimum number is 4. We have ",ntrack_obs
           ierr=102
           return
        else if(ntrack_rec_mk5 .gt. 32 .and. kvrack) then
         write(luscn,'(/,a)')"PROC_MK5_INIT1: Too many tracks for VLBA!"
         write(luscn,'(a)') "Maximum is 32. We have ",ntrack_rec_mk5
         ierr=103
        endif
! put commands in setup.
        if(km4form) then
          write(lufile,90) "Connect the Set 1 Mark 5A recorder input "
          write(lufile,90) "to the headstack 1 output of the formatter"
          if(ntrack_rec_mk5 .gt. 32) then
             write(lufile,90)
     >          "Connect the Set 2 Mark 5A recorder input"
             write(lufile,90)
     >          "to the headstack 2 output of the formatter"
          endif
        else if(kvrack) then
            write(lufile,90)"Connect the Mark5A recorder to the"
            write(lufile,90)"second recorder output of the formatter"
        endif
      endif
      return
90    format('"',a,'"')
      end
