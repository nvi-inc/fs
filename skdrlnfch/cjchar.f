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
      function cjchar(iar,i)
C
C CJCHAR: returns the Ith character in hollerith array IAR
C
C  040506  ZMM  changed from character to character*1
C               changed type from integer to integer*2
C               removed trailing RETURN

      implicit none

      character*1 cjchar
! AEM 20041230 int*2 -> int      
      integer i
      integer*2 iar(*)
C
      call hol2char(iar,i,i,cjchar)

      end
