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
      subroutine i32ma(ibuf,iat,imix,isw1,isw2,isw3,isw4,ipcal)
C 
C     I32MA converts data for the IF3 distributor to an MAT buffer.
C 
C  INPUT: 
C 
C     IBUF - buffer to use
C     IAT - attenuator setting
      integer*2 ibuf(1) 
C 
C     The buffer is set up as follows:
C                       0000csab
C     where each letter represents a character (half word). 
C                   0  = these bits unused
C                   c  = bit 1 (bit 0 is LSB) pcal on=0,off=1
C                   s  = switch setting
C                   a  = mixer, and high bits of atten.
C                   b  = remaining atten. bits
C 
C  Fill unused fields with zeros 
C
      call ifill_ch(ibuf,1,4,'0') 
C
      ipch=(1-ipcal)*2
      call ichmv(ibuf,5,ihx2a(ipch),2,1) 
C      
      iswh=(2-isw1)+(2-isw2)*2+(2-isw3)*4+(2-isw4)*8
      call ichmv(ibuf,6,ihx2a(iswh),2,1) 
c
C  Put upper two bits (of six) into char 7 plus mixer control
c
      call ichmv(ibuf,7,ihx2a((2-imix)*4+and(iat,o'60')/o'20'),2,1)
c
C  Put lower four bits into next character.
c
      call ichmv(ibuf,8,ihx2a(and(iat,o'17')),2,1)
C 
      return
      end 
