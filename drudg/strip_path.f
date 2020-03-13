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
      subroutine strip_path(lfullpath,lfilnam)
! strip off the path, return the filename.
      implicit none
! fucntions
      integer trimlen
! passed
      character*(*) lfullpath           !passed
      character*(*) lfilnam             !filename
! local
      integer ilen
      integer i
      integer ilast_non_blank
      integer islash

      ilen=len(lfullpath)

      ilast_non_blank=trimlen(lfullpath)
      if(ilast_non_blank .eq. 0) then
        lfilnam=" "
        return
      endif

      islash=0
      do i=ilast_non_blank,1,-1
        if(lfullpath(i:i) .eq. "/") then
           islash=i
           goto 10
        endif
      end do

10    continue
      if(ilast_non_blank-islash .gt. ilen) then
         lfilnam=lfullpath(islash+1:islash+ilen)
      else
         lfilnam=" "
         lfilnam=lfullpath(islash+1:ilast_non_blank)
      endif
      return
      end
