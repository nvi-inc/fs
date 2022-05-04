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
      subroutine snap_enable()
      implicit none  !2020Jun15 JMGipson automatically inserted.
!     JMGipson   2002Jan02  V1.00
      include 'hardware.ftni'

      if(krec_append) then
        write(luFile,'("enable",a1,"=")', err=100) crec(irec)
      else
        write(luFile,'("enable=")', err=100)
      endif

      return
100   continue
      return
      end

