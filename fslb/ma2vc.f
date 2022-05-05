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
      subroutine ma2vc(ibuf1,ibuf2,lfreq,ibw,itp,iatu,iatl,irem,ilok, 
     .     tpwr,ial)

C  convert mat buffer to vc data c#870407:12:40#
C 
C     This routine converts the buffers returned from the MAT 
C     into the video converter indices, frequency, and total power. 
C 
C  INPUT: 
C 
      integer*2 ibuf1(1),ibuf2(1) 
C      - buffers of length 5 words, as returned from MATCN
C 
C  OUTPUT:
C 
      integer*2 lfreq(3)
C      - frequency, ASCII characters in format fff.ff (MHz) 
C     IBW - bandwidth code
C     ITP - TPI selection code
C     IATU, IATL - upper, lower attenuator settings 
C     IREM - remote/local code
C     ILOK - lock/unlock code 
C     TPWR - total power, binary
C     IAL  - alarm
C 
C 
C     Buffers from MATCN look like: 
C     for ! data:   Vntabfffff
C     for % data:   Vn----pppp (total power word) 
C     Note we are only concerned with the last 8 characters 
C 
      call ichmv(lfreq,1,ibuf1,6,3) 
      call ichmv_ch(lfreq,4,'.')
      call ichmv(lfreq,5,ibuf1,9,2) 
      ibw = ia2hx(ibuf1,5)
      itp = and(ia2hx(ibuf1,3),7)
      ia = ia2hx(ibuf1,4) 
      iatu = 10*and(ia,2)/2
      iatl = 10*and(ia,1)
      irem = and(ia2hx(ibuf1,3),8)/8 
      ilok = and(ia,8)/8 
      tpwr = 0.0
      do i=1,4
        tpwr = tpwr + ia2hx(ibuf2,6+i)*(16.0**(4-i))
      enddo
      ial = and(ia,4)/4
c
      return
      end 
