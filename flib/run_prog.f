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
      subroutine run_prog(name,wait,ip1,ip2,ip3,ip4,ip5)
      implicit none
      character*(*) name,wait
      integer*4 ip1,ip2,ip3,ip4,ip5
c
      integer*4 ip(5)
c
      ip(1)=ip1
      ip(2)=ip2
      ip(3)=ip3
      ip(4)=ip4
      ip(5)=ip5
      call fc_skd_run(name,wait,ip)
c
      return
      end
