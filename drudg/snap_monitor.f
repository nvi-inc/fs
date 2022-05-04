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
      subroutine snap_monitor(kin2net)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'
!  2014Jan31. Removed  tape based stuff.

      logical kin2net

      if(Km5Disk) then
        if(kin2net) then
          write(luFile,'("in2net")')
        else if(.not.kflexbuff) then
          write(luFile,'("disk_pos")')
        endif
      endif

      return
      end
