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
!     Last change:  JG   12 May 2000    8:09 am
!*************************************************************************
      function iwhere_in_string_list(list,num_list,lvalue)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      INTEGER iwhere_in_string_list
      INTEGER num_list
      CHARACTER*(*) list(*),lvalue

      do iwhere_in_string_list=1,num_list
        IF(lvalue .EQ. list(iwhere_in_string_list)) return
      end do
      iwhere_in_string_list=0
      return
      END

