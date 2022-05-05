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
      subroutine snap_data_valid(lstring)
!     JMGipson   2002Jan02  V1.00
      include 'hardware.ftni'
      character*(*) lstring

! Output "et" command.
      if(krec_append) then
        write(luFile,'("data_valid",a1,a)', err=100) crec(irec),lstring
      else
        write(luFile,'("data_valid",a)', err=100) lstring
      endif

      return
100   continue
      return
      end

