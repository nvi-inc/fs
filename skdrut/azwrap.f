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
      real*4 FUNCTION azwrap(az,cwrap,azwrap_limits)
! Given input value, compute azimuth including wrap
      implicit none
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'

      real*4 az
      character*(*)  cwrap        ! one or two characters. 
                                   !"-" or " " = neutral
                                   !"W"        = counter
                                   !"C"        = clock 

      real*4 azwrap_limits(1:2)    !min, max values of wrap

! tolerance to see how close we are to azimuth wrap
      real*4 az_tol
      parameter(az_tol=5.d0*deg2rad)

      azwrap=az

! Find correct position of beginning AZ, including wrap.
      IF (azwrap.LT.azwrap_limits(1)) then
           azwrap=azwrap+TWOPI

      else if(azwrap - azwrap_limits(1) .lt. az_tol .and.
     >   (cwrap .eq. " " .or. cwrap .eq. "-")) then
! Slightly above boundary separating neutral and CCW.
! Wrap indicates neutral, but should probably be clockwise-- source wandered from N to C
         if(azwrap+twopi .lt. azwrap_limits(2)) azwrap=azwrap+twopi               
      endif

      if(cwrap .eq."C") then
         if(azwrap+twopi .lt. azwrap_limits(2)) azwrap=azwrap+twopi           
      endif
      return
      end 


