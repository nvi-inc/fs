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
C@PID_STR

      subroutine pid_str (cpid,pid)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C Pid_str constructs a character string from the given process
C ID number.
C
C -P. Ryan

      integer     pid,i,j,k
      character*(*) cpid

C get character string from integer

      k = pid
      do i=5,1,-1
        j = (k - ((k/10)*10))
        write (cpid(i:i),1000) j
        k = k/10
      end do
1000  format (i1)

      return
      end

