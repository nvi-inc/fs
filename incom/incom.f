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
      program incom
      implicit none
c
c rdg 010529 added ip and changed the call to sincom.
c            also added conditional code to errors.
c
      include '../include/fscom.i'
c
      integer*4 ip(5)

      ip(3)=0
      call setup_fscom
      call fmperror_standalone_set(0)
      call sincom(ip)
      if(ip(3).ne.0) call fc_exit(-1)
      call write_fscom
c
      end
