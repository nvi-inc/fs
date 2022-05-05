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
      subroutine ma2en4(ibuf,iena,kena)
      integer*2 ibuf(1)
      integer iena
      logical kena(2)
C
C     For Mark IV:
C     % data:       TPrxxxxyxz
C                rxxxxxxt represents bits 0 - 31, 0 starting at z
C     where the r will have   bit31 = 1 for record enabled.
C                             remaining bits will be 0.
C               y will have   bit8 = 1 for stack1 enabled 
C               z will have   bit0 = 1 for stack2 enabled 
C                             remaining bits will be 0.
C
      iena=and(ia2hx(ibuf,3)/8,1)
      kena(1)=1.eq.and(ia2hx(ibuf,10),1)
      kena(2)=1.eq.and(ia2hx(ibuf,8),1)
C
      return
      end
