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
      subroutine mpstar_rad(tjd,rarad,decrad)
! do precession when args are input in radians
      implicit none
      include "../skdrincl/constants.ftni"
      double precision rarad,decrad

      double precision rah,decd,radh,decdd,tjd ! for APSTAR

      rah = RARAD*Rad2Ha
      decd = DECRAD*Rad2Deg
      call mpstar(tjd,3,rah,decd,radh,decdd)
      RARAD=radh*hA2rad
      DECRAD=decdd*deg2rad
      return
      end

