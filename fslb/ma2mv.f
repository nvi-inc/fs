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
      subroutine ma2mv(ibuf,idir,isp,lgen)

C  convert mat buffer to mv data
C 
C     This routine converts the buffers returned from the MAT 
C     into the tape motion information. 
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffers of length 5 words, as returned from MATCN
C 
C  OUTPUT:
C 
C     IDIR - direction
C     ISP - speed 
      integer*2 lgen(1) 
C       - rate generator frequency
C 
C 
C     The format of the buffer from MATCN is: 
C        TPsrrr0000 
C     where each letter is a character with the following bits
C                  s = direction (top bit) and speed (3 bits) 
C            rrr = 3 digit rate, ASCII value 720 or 960 
C     Note we are only concerned with the last 8 characters 
C 
      ia = ia2hx(ibuf,3)
      isp = and(ia,7)
      idir = and(ia,8)/8 
      call ichmv(lgen,1,ibuf,4,3) 
C 
      return
      end 
