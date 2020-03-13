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
      subroutine drudg_write_comment(lu, lstring)

! Write a comment line. This is text preceded by double quotes. 
! Does not do any processing of comment line except for truncation at last blank.
! 2018Sep05. First version.
 
      implicit none 
      integer lu
      character*(*) lstring
! local
      integer nch
      character*1 lq
! function
      integer trimlen
      lq='"'
   
   
      nch=trimlen(lstring)

      write(lu,'(a,a)') lq,lstring(1:nch)
      return
      end 




