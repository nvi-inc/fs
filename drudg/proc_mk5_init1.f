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
      integer i

      ierr=0

! Put some instructions out for MK5 recorders.
      if(km5p) then
        if(km4form) then
           write(lufile,90)"connect the Mark 5P recorder to the"
           write(lufile,90)"headstack 2 output of the formatter"
         else if(kvrack) then
           write(lufile,90)"connect the Mark 5P recorder to the"
           write(lufile,90)"second recorder output of the formatter"
         endif
      else if(km5) then
! setup for number of tracks observed and recorded.
        if(ntrack_obs .lt. 4) then
           write(luscn,*) "PROC_MK5_INIT1: Too few tracks in Mk5 mode!"
           write(luscn,*) "Minimum number is 4. We have ",ntrack_obs
           ierr=101
           return
        else if(ntrack_rec_mk5 .gt. 32 .and. kvrack) then
           write(luscn,*) "PROC_MK5_INIT1: Too many tracks for VLBA!"
           write(luscn,*) "Maximum is 32. We have ",ntrack_obs
           ierr=102
        endif
! put commands in setup.
        if(km4form) then
          write(lufile,90)"connect the Set 1 Mark 5A recorder input "
          write(lufile,90)"to the headstack 1 output of the formatter"
          if(ntrack_rec_mk5 .gt. 32) then
            write(lufile,90)"connect the Set 2 Mark 5A recorder input"
            write(lufile,90)"to the headstack 2 output of the formatter"
          endif
        else if(kvrack) then
          write(lufile,90)"connect the Mark 5A recorder to the"
          write(lufile,90)"second recorder output of the formatter"
        endif
      endif
      return
90    format('"',a,'"')
      end

