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
      subroutine add_slash_if_needed(lstring)  
      implicit none 
! Make sure last character is a slash. If not, make it one.
! passed & returned string
      character*(*) lstring
! function
      integer trimlen
! local variables.
      integer nch
      integer ilen

      ilen=len(lstring)

      nch=trimlen(lstring)

      if(nch .gt. 0) then
        if(lstring(nch:nch) .ne. "/") then
          if(nch .lt. ilen) then
             nch=nch+1
          else
             write(*,*)
     >      "WARNGIN: add_slash_if_needed: Not enough space to add '/'"
             write(*,*) "Replacing last character!"
          endif
          lstring(nch:nch)="/"
        endif
      endif
      return
      end






