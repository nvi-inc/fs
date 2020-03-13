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
      subroutine make_unit_vector(phi,theta,vec)
! Make a unit vector
! input
      double precision phi, theta       !spherical  cooordiantes=long,lat
                                        !both in radians.
! ouptut
      double precision vec(3)
! History:
! 2007Oct05  JMGipson. First version.

! start of code
      vec(1)=cos(phi)*cos(theta)
      vec(2)=sin(phi)*cos(theta)
      vec(3)=sin(theta)
      return
      end
