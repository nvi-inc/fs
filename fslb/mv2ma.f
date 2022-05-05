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
      subroutine mv2ma(ibuf,idir,isp,lgen)

C  convert mv data to mat buffer
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
      integer*2 lgen(1) 
C      - rate generator, ASCII 720 or 880 
C     IDIR - direction
C     ISP - speed 
C 
C     Format the buffer for the controller. 
C     The buffer is set up as follows:
C                   )srrr0000 
C     where each letter represents a character (half word). 
C                   s  = speed (lower 3 bits) and direction (top bit) 
C                 rrr  = rate generator frequency 
C 
      call ichmv_ch(ibuf,1,')') 
      call ichmv(ibuf,2,ihx2a(idir*o'10'+isp),2,1)
      call ichmv(ibuf,3,lgen,1,3) 
      call ifill_ch(ibuf,6,4,'0') 
C 
      return
      end 
