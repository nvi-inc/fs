      subroutine snap_recalc_speed(luscn,kvex,speed_ft,ls2speed,ibuf)

      implicit none
      include 'hardware.ftni'
! function
      character lower
! passed.
      integer luscn             !luscreen
      logical kvex
      real speed_ft
      integer*2 ls2speed(2)             !holerith 'speed' for S2
      integer*2 ibuf(50)                !io buffer from scedule

! Calculate stop time.
      if(ks2) then
        itime2stop=0
      else if(speed_ft .gt. 15.0) then
        itime2stop=5
      else
        itime2stop=3
      endif
! get ascii version of speed.
      if(.not.km5) then
        lspeed=" "
        if(ks2) then
          if(kvex) then
            ispeed(1)=ls2speed(1)
            ispeed(2)=ls2speed(2)
            call c2lower(lspeed,lspeed)
          else
            lspeed="slp"
          endif
          nspdCh=4
        else if(.not.kk4) then
          speed_inches = 12.0*speed_ft
          call spdstr(speed_inches,ispeed,nspdCh)   !return speed as holerith in ispeed.
          if (nspdCh.le.0) then
            write(luscn,'("SNAP_RECALC_SPEED: Illegal speed! ",f6.2)')
     >          speed_inches
            write(luscn,'("After: ",40a2)') ibuf(1:40)
            stop
          endif
        endif
      endif
      return
      end
