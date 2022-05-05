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
      subroutine make_unit(rlong,rlat,xyz)

! passed
      double precision rlong     !longitude (radians)
      double precision rlat      !latitude
! on output
      double precision xyz(3)  !contains unit vectors along minimum elevation.
! local
      double precision sin_long,cos_long,sin_lat,cos_lat

      sin_long=sin(rlong)
      cos_long=cos(rlong)
      sin_lat =sin(rlat)
      cos_lat =cos(rlat)

      xyz(1)=cos_lat*cos_long
      xyz(2)=-sin_long
      xyz(3)=-sin_lat*cos_long
      return
      end


