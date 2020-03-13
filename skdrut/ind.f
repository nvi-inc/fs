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
        integer function ind (istr1,ifc1,ilc1,istr2,ifc2,ilc2)

C Ind can perform the functions of either ISCNC or ISCNS more efficiently
C by calling Index, a Fortran library routine.  Ind returns the index
C in istr1 of where strings istr1 and istr2 match.  If there is no match,
C it returns a -1.
C 951017 nrv Change to I*2 for hollerith 

        implicit none

C Input
        integer*2   istr1(*),istr2(*) ! two strings to be searched
        integer     ifc1,ilc1,ifc2,ilc2 !first,last range in strings

C Local
        integer j,index
        character*600 cs1,cs2

C clear buffers

        cs1=' '
        cs2=' '

C convert to character strings

        call hol2char (istr1,ifc1,ilc1,cs1)
        call hol2char (istr2,ifc2,ilc2,cs2)

C call library function, return relative index

        j = index (cs1(1:ilc1-ifc1+1),cs2(1:ilc2-ifc2+1))

        if (j .ne. 0) then
          if (ifc1 .gt. 1) then ! didn't start at beginning of string
            ind = ifc1 + j - 1
          else
            ind = j
          end if
        else
          ind = -1
        end if
        return
        end

