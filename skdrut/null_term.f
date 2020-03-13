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
      subroutine null_term(cstr)

! AEM 20041125 add implicit none
      implicit none
c
c   'null_term' will null-terminate a character string.  This
c   is necessary when string must be passed to C routines.
c
C 990916 nrv Uncommented the warning message if the string is too short.

      character*(*) cstr
      integer i,j,len

      j = len(cstr)

      i = j
      do while ((i.gt.0) .and. ((cstr(i:i).eq.' ').or.
     .         (cstr(i:i) .eq. char(0))))
        i = i - 1
      end do
      i = i + 1
      if (i .gt. j) then ! no trailing blanks or nulls
        print*, 'NULL_TERM: string too short, last char replaced ',
     .  'with NULL'
        i=i-1
      end if
      cstr(i:i) = char(0)

      return
      end

