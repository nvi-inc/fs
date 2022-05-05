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
      subroutine squeezeleft(lstring,ilast_non_blank)
! remove blank space.
      implicit none
      character*(*) lstring
      integer ilast_non_blank
! local
      integer ilen
      integer i
      integer iptr
      ilen=len(lstring)

      iptr=1
      do i=1,ilen
        if(lstring(i:i) .ne. " ") then
           lstring(iptr:iptr)=lstring(i:i)
           iptr=iptr+1
        endif
      end do
      if(iptr .le. ilen) then
         lstring(iptr:ilen) = " "       !put spaces at the end.
      endif
      ilast_non_blank=iptr-1
      return
      end






