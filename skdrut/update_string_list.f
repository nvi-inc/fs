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
      subroutine update_string_list(cstring_list,
     >     num_in_list,max_in_list,cstring,iptr)
! Find where cstring is in cstring_list.
! If it is in the list, return iptr.
! If it is not, and there is enough space, put it at the end.
! If not enough space, return an error.
! on entry
!
      implicit none
      integer num_in_list                       !number in list now.
      integer max_in_list                       !maximum allowed
      character*(*) cstring_list(max_in_list)      !The list
      character*(*) cstring                     !String to check
      integer iptr                              !-1 if no space, otherwise location.
!
! History.
!  2005Nov21  JMGipson.  First version.
!
! functions
      integer iwhere_in_string_list
! local variables

      iptr=iwhere_in_string_list(cstring_list,num_in_list,cstring)
      if(iptr .eq. 0) then
        if(num_in_list .lt. max_in_list) then
          num_in_list=num_in_list+1
          cstring_list(num_in_list)=cstring
          iptr=num_in_list
        else
          iptr=-1
        endif
      endif
      return
      end
