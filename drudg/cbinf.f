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
      subroutine cbinf(cable,wrap)

C     CBINF returns a printable string telling which wrap
C     corresponds to the single hollerith character input.
C  940131 nrv created

C  Input:
      character*2 cable
C  Output
      character*7 wrap ! 'NEUTRAL', 'CW', or 'CCW'

C  Local
      character*2 cable_in

C  Initialized
      cable_in=cable
      call capitalize(cable_in)
      if(cable_in(1:1) .eq. "-") then
        wrap='neutral'
      else if(cable_in(1:1) .eq. "C") then
        wrap='cw'
      else if(cable_in(1:1) .eq. "W") then
        wrap='ccw'
      else
        wrap=' '
      endif

      return
      end
      
