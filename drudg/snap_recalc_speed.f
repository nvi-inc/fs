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
      subroutine snap_recalc_speed(luscn,kvex,speed_ft,cs2speed,
     >   cspeed,ierr)
      implicit none  !2020Jun15 JMGipson automatically inserted.

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
