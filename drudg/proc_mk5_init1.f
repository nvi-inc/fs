      subroutine proc_mk5_init1(ntrack_obs,ntrack_rec_mk5,luscn,ierr)
      implicit none
      include 'hardware.ftni'
! passed
      integer ntrack_obs       !number of tracks we normally record on
      integer ntrack_rec_mk5   !number we actually used  in mk5 (must be 8,16,32 or 64
      integer luscn            !LU to output error messages (normally the screen).
! returned
      integer ierr             !some error

      ierr=0
      if((km5a_piggy.or.km5p_piggy) .and. ntrack_rec_mk5 .gt. 32)then
         write(luscn,'(/,a)')
     >      "PROC_MK5_INIT1: Can't piggyback with more than 32 tracks!"
        ierr=101
        return
      endif

! Put some instructions out for MK5 recorders.


      if(km5A_piggy.or. KM5P_Piggy) then
! Output instructions for the recorders. These are common both piggyback and Mark5P mode.
        if(km4form .or. kvrack) then
          write(lufile,90)  "Connect the tape recorder to the "
          if(km4form) then
            write(lufile,90)"headstack 1 output of the formatter."
          else if(kvrack) then
            write(lufile,90)"first recorder output of the formatter."
          endif
         endif
         if(km5a_piggy) then
           write(lufile,90)
     >       "Connect the Set 1 Mark5A recorder input to the"
         else
           write(lufile,90)
     >       "Connect the Mark5P recorder input to the"
         endif
         if(km4form) then
           write(lufile,90)"headstack 2 output of the formatter."
         else if(kvrack) then
           write(lufile,90)"second recorder output of the formatter."
         endif
      else if(KM5P) then
         write(lufile,90)
     >       "Connect the Mark5P recorder input to the"
         if(km4form) then
            write(lufile,90) "the headstack 1 output of the formatter"
         else
            write(lufile,90)"first recorder output of the formatter"
         endif
      else if(km5A) then
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
          write(lufile,90) "Connect the Set 1 Mark 5A recorder input to"
          if(km5APigWire(1) .or.Km5APigWire(2)) then
            write(lufile,90) "the headstack 2 output of the formatter"
          else
            write(lufile,90) "the headstack 1 output of the formatter"
          endif
          if(ntrack_rec_mk5 .gt. 32) then
             write(lufile,90)
     >          "Connect the Set 2 Mark 5A recorder input"
             write(lufile,90)
     >          "to the headstack 2 output of the formatter"
          endif
        else if(kvrack) then
            write(lufile,90)"Connect the Set 1 Mark5A recorder to the"
            if(km5APigWire(1) .or.Km5Apigwire(2)) then
              write(lufile,90)"second recorder output of the formatter"
            else
              write(lufile,90)"first recorder output of the formatter"
            endif
        endif
      endif
      return
90    format('"',a,'"')
      end
