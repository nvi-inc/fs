      subroutine snap_recalc_speed(luscn,kvex,speed_ft,cs2speed,
     >   cspeed,ierr)

      include 'hardware.ftni'
      integer ierr
! 2005Apr26  JMGipson  Made cs2speed ascii.

! passed.
      integer luscn             !luscreen
      logical kvex
      real speed_ft
      character*4 cs2speed
      character*8 cspeed

      ierr=0
! Calculate stop time.
      if(ks2) then
        itime2stop=0
      else if(speed_ft .gt. 15.0) then
        itime2stop=5
      else
        itime2stop=3
      endif
! get ascii version of speed.
      cspeed=" "
      if(km5Disk) then
        continue
      else if(ks2) then
          if(kvex) then
            cspeed=cs2speed
            call c2lower(cspeed,cspeed)
          else
            cspeed="slp"
          endif
      else if(.not.kk4) then
        speed_inches = 12.0*speed_ft
        call spdstr(speed_inches,cspeed,ierr)   !return speed as ASCII in ispeed.
      endif
      return
      end
