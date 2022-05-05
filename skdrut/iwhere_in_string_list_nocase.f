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
!*************************************************************************
      function iwhere_in_string_list_nocase(list,num_list,lvalue)
      implicit none
! 2019Nov20 WEH  made list_tmp, lvalue_tmp fixed lenght for backward compatibility with f77
! find a string match ignoring case
      INTEGER iwhere_in_string_list_nocase
      INTEGER num_list
      CHARACTER*(*) list(*),lvalue
      character*256   list_tmp
      character*256 lvalue_tmp

      do iwhere_in_string_list_nocase=1,num_list
        list_tmp=list(iwhere_in_string_list_nocase)
        lvalue_tmp=lvalue
        call capitalize(list_tmp)
        call capitalize(lvalue_tmp)
        if(lvalue_tmp .eq. list_tmp) return     
      end do
      iwhere_in_string_list_nocase=0
      return
      END

