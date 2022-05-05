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
      subroutine ma2rp(ibuf,irem,iby,ieq,ibw,ita,itb,ial)

C  convert mat buffer to rp data
C 
C     This routine converts the buffers returned from the MAT 
C     into the reproduce tracks information.
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffers of length 5 words, as returned from MATCN
C 
C  OUTPUT:
C 
C     IREM - remote/local 
C     IBY - bypass or not 
C     IEQ - equalizer setting 
C     IBW - bandwidth setting 
C     ITA - track A 
C     ITB - track B 
C     IAL - alarm 
C 
C 
C     Buffers from MATCN look like: 
C                  ! data in IBUF:   TPrdebtbta 
C     where each letter is a character with the following bits
C                   r = reset, alarm, local 
C                   d = bypass, disable tracks
C                   e = equalizer 
C                   b = bandwidth 
C                   tb = track B
C                   ta = track A
C 
C     Note we are only concerned with the last 8 characters 
C 
C 
      ita = ia2hx(ibuf,9)*10 + ia2hx(ibuf,10) 
      itb = ia2hx(ibuf,7)*10 + ia2hx(ibuf,8)
      ibw = and(ia2hx(ibuf,6),7) 
      ieq = ia2hx(ibuf,5) 
      iby = and(ia2hx(ibuf,4),2)/2 
      ial = and(ia2hx(ibuf,3),4)/4 
      irem = and(ia2hx(ibuf,3),8)/8
C 
      return
      end 
