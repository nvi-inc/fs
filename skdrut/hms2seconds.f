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
      double precision function hms2seconds(ih,im,is)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      integer ih,im,is
! convert time in hours, minutes,seconds format to seconds
!      hms2seconds=ih*3600+im*60.+is
! AEM 20041227
      hms2seconds=ih*3600.d0+im*60.d0+is
      return
      end
