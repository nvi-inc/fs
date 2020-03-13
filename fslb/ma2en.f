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
      subroutine ma2en(ibuf,iena,itrk,ntrk)

C  convert mat buffer to en data c#870407:12:41#
C 
C     This routine converts the buffers returned from the MAT 
C     into the enabled track information. 
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffers of length 5 words, as returned from MATCN
C 
C  OUTPUT:
C 
C     IENA - general enable bit ("record" button) 
      integer itrk(28)
C      - enabled tracks 
C     NTRK - number of tracks enabled (i.e. # of 1s in ITRK)
C 
C 
C     Buffers from MATCN look like: 
C     for % data:   TPtttttttt
C     where each "t" contains 3 or 4 bits regarding tape track status 
C 
C     Note we are only concerned with the last 8 characters 
C 
C 
      do 120 i=1,2
        ic = 10 
        if (i.eq.2) ic = 8
        do 110 j=i,16,14
          ia = ia2hx(ibuf,ic) 
          itrk(j) = and(ia,1)
          itrk(j+2) = and(ia,2)/2
          itrk(j+4) = and(ia,4)/4
          itrk(j+6) = and(ia,8)/8
          ia = ia2hx(ibuf,ic-1) 
          itrk(j+8) = and(ia,1)
          itrk(j+10) = and(ia,2)/2 
          itrk(j+12) = and(ia,4)/4 
          ic = ic - 4 
110       continue
120     continue
C 
      ntrk = 0
      do 130 i=1,28 
        if (itrk(i).eq.1) ntrk = ntrk + 1 
130     continue
C 
      iena = and(ia,8)/8 
C 
      return
      end 
