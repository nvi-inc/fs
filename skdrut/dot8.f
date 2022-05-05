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
!     Last change:  JG   27 May 2005    3:05 pm
      function dot8(a,b,num)
      DOUBLE precision a(*),b(*)
      INTEGER num,i
      DOUBLE PRECISION dot8

      dot8=0.
      do i=1,num
        dot8=dot8+a(i)*b(i)
      end do
      return
      end
