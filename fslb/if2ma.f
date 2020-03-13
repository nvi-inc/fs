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
      subroutine if2ma(ibuf,iat1,iat2,inp1,inp2)
C 
C     IF2MA converts data for the IF distributor to an MAT buffer.
C 
C  INPUT: 
C 
C     IBUF - buffer to use
C     INP1,2 - the IFD's input type 
C     IAT1,2 - attenuator settings
      integer*2 ibuf(1) 
cxx      integer ibuf(1) 
C 
C     The buffer is set up as follows:
C                       00ija2a1
C     where each letter represents a character (half word). 
C                   00 = these bits unused
C                   i  = input for IF 2 (0=NOR,8=ALT) 
C                   j  = input for IF 1  (0=NOR,8=ALT)
C                   a2 = atten. setting for IF 2
C                   a1 = atten. setting for IF 1
C 
      call ifill_ch(ibuf,1,2,'0') 
C  Fill unused fields with zeros 
      call ib2as(inp2*8,ibuf,3,1) 
      call ib2as(inp1*8,ibuf,4,1) 
C  Put inputs into chars 3,4 
C 
      call ichmv(ibuf,7,ihx2a(and(iat1,o'60')/16),2,1) 
C  Put upper two bits (of six) into char 7 
      call ichmv(ibuf,8,ihx2a(and(iat1,o'17')),2,1)
C  Put lower four bits into next character.
      call ichmv(ibuf,5,ihx2a(and(iat2,o'60')/16),2,1) 
      call ichmv(ibuf,6,ihx2a(and(iat2,o'17')),2,1)
C  Do the same for channel 2 
C 
      return
      end 
