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
C@UPPER

! AEM 20041223 char -> char*1
      character*1 function upper(c)
C
C        if c is a character, return its uppercase value.  otherwise
C     return it unchanged.
C
C     891228 PMR created

! AEM 20041223 char -> char*1
      character*1 c

      if ((c.ge.'a').and.(c.le.'z')) then
         upper = char(ichar(c) - (ichar('a') - ichar('A')))
      else
         upper = c
      end if

      return
      end
