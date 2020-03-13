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
      subroutine xyz2latlon(XYZ,rlat,rlon)
! convert from xyz to lat long
!
      include '../skdrincl/constants.ftni'

      double precision xyz(3)
      double precision rlat,rlon

      rlon = (-DATAN2(XYZ(2),XYZ(1)))*rad2deg
      IF (rlon.LT.0.D0) rlon=rlon+360.D0
C                   West longitude = ATAN(y/x)
      rlat=DATAN2(XYZ(3),DSQRT((XYZ(1)**2+XYZ(2)**2))*(1.D0-EFLAT)**2)
     >          * rad2deg
      return
      end



