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
      subroutine snap_wait_sec(iseconds)
!     JMGipson   2002Jan02  V1.00
      include 'hardware.ftni'
      integer iseconds

! issue wait command.
      if(iseconds .lt. 10) then
        write(luFile,'("!+",i1,"s")') iseconds
      else if(iseconds .lt. 100) then
        write(luFile,'("!+",i2,"s")') iseconds
      else
        write(*,*) "Wait too long!"
      endif
      return
      end
