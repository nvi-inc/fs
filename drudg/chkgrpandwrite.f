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
      subroutine ChkGrpAndWrite(itrk2,istart,iend,ihead,
     >  cname,kfound,cbuf,nch)
      implicit none

! Passed variables
      integer istart,iend       !starting, ending location for test.
      integer ihead             !which headstack, 1 or 2?
      character*2 cname         !name of group (if found)
! modified
      integer itrk2(36,2)       !If we find group, then we set corresponding tracks to 0.
      logical kfound            !all tracks that we look at have 1.
      character*(*) cbuf        !buffer to write.
      integer nch               !Number of characters so far.
! local
      integer i

! 0. See if we find this group. All tracks must be set.
      kfound=.true.
      do i=istart,iend,2
        if(itrk2(i,ihead) .eq. 0) then
           kfound=.false.
           return
         endif
      end do
! Group found. Some more processing.

! 1. Zero the second track list
      do i=istart,iend,2
         itrk2(i,ihead)=0
      end do
! 2. put info in the buffer.
      cbuf(nch:nch+3)=cname//","
      nch=nch+3
      return
      end


















