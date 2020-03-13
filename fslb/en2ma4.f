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
      subroutine en2ma4(ibuf,iena,kena)
C     convert en data to mat buffer for Mark IV drive.
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
      logical kena(2) 
C      - true for head stacks enabled index 1 = stack 0
C                                     index 2 = stack 1
C     IENA - record-enable bit
C 
C  LOCAL: 
C
      integer ia,ib
C 
C     Format the buffer for the controller. 
C 
      call ichmv_ch(ibuf,1,'%') 
C                   The strobe character for this control word
      call ichmv_ch(ibuf,2,'00000000') 
C                   Fill buffer with zeros to start 
      ia = iena*8
      call ichmv(ibuf,2,ihx2a(ia),2,1)
      ia = 0
      ib = 0
      if (kena(1)) call ichmv(ibuf,9,ihx2a(z'01'),2,1)
      if (kena(2)) call ichmv(ibuf,7,ihx2a(z'01'),2,1)
C
      return
      end 
