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
C@APOSN

       subroutine aposn(rlu,err,irec_no,irb,ioff)
c
c      Position the file pointer at record IREC_NO.  IRB and
c      IOFF are ignored.
c
c      89006  PMR
c
       implicit none
       integer ifptr
       common /position/ ifptr(256)

       integer rlu,err,irb,ioff
       integer irec_no

       integer j, next

       next = ifptr(rlu)
       if (irec_no .lt. next) then
           j = 1
           do while ((j.le.(next - irec_no)).and.(err.eq.0))
               j = j + 1
               call backward(rlu,err)
           end do
       else if (irec_no .gt. next) then
           j = 1
           do while((j.le.(irec_no - next)).and.(err.eq.0))
               j = j + 1
               call forward(rlu,err)
           end do
       end if

       return
       end

