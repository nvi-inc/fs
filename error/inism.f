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
      subroutine inism(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms,
     +                 wdisum,crssum,crsrms,wcrsum,igp)
C
      double precision lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms
      double precision wdisum,crssum,crsrms,wcrsum
C
      lonsum=0.d0
      latsum=0.d0
      lonrms=0.d0
      latrms=0.d0
      wlnsum=0.d0
      wltsum=0.d0
      dirms=0.d0
      wdisum=0.0d0
      crssum=0.0d0
      crsrms=0.0d0
      wcrsum=0.0d0
      igp=0
C
      return
      end
