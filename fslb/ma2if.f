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
      subroutine ma2if(ibuf1,ibuf2,iat1,iat2,inp1,inp2,tp1,tp2,irem)

C  convert mat buffer to if data c#870407:12:40#
C 
C     This routine converts the buffers returned from the MAT 
C     into the IF distributor attenuators, inputs, and total power. 
C 
C  INPUT: 
C 
      integer*2 ibuf1(1),ibuf2(1) 
C      - buffers of length 5 words, as returned from MATCN
C      - buffer 1 contains the settings 
C      - buffer 2 contains the total powers 
C 
C  OUTPUT:
C 
C     IAT1 - attenuator setting, IF1
C     IAT2 - attenuator setting, IF2
C     INP1 - input selection, IF1 
C     INP2 - input selection, IF2 
C     TP1 - total power reading, IF1, binary
C     TP2 - total power reading, IF2, binary
C     IREM - remote/local setting 
C 
C 
C     Buffers from MATCN look like: 
C      ! data:      IFttttpppp
C     where each character has 4 bits of the total power value: 
C                   tttt - IF2 total power
C                   pppp - IF1 total power
C      % data:      IFr0ija2a1
C     where 
C                   r = one bit denoting rem/lcl
C                   0 = a fixed zero
C                   i = IF2 input, 0=NOR, 8=ALT 
C                   j = IF1 input, 0=NOR, 8=ALT 
C                   a1= atten. 1 (2 bits first char., other 4 in second)
C                   a2= atten. 2 (2 bits first char., other 4 in second)
C
C
      iat1 = 16*and(ia2hx(ibuf1,9),3) + ia2hx(ibuf1,10)
C  Atten: upper 2 bits from char 9, lower 4 from char 10
      iat2 = 16*and(ia2hx(ibuf1,7),3) + ia2hx(ibuf1,8)
      inp1 = ia2hx(ibuf1,6)/8
      inp2 = ia2hx(ibuf1,5)/8
      irem = ia2hx(ibuf1,3)/8
C
c     tp1 = o'10000'*float(ia2hx(ibuf2,7)) + o'400'*ia2hx(ibuf2,8)
c    .     + o'20'*ia2hx(ibuf2,9) + ia2hx(ibuf2,10)
      tp1 = o'10000'*ia2hx(ibuf2,7) + o'400'*ia2hx(ibuf2,8)
     .     + o'20'*ia2hx(ibuf2,9) + ia2hx(ibuf2,10)
C  Pick up four bits from each character for TP
      tp2 = o'10000'*ia2hx(ibuf2,3) + o'400'*ia2hx(ibuf2,4)
     .     + o'20'*ia2hx(ibuf2,5) + ia2hx(ibuf2,6)
C  Pick up four bits from each character for TP
C
      return
      end
