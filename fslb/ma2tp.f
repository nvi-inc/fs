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
      subroutine ma2tp(ibuf,ilow,lft,ifas,icap,istp,itac,irdy)

C  convert mat buffer to tp data c#870407:12:42#
C
C     This routine converts the buffers returned from the MAT
C     into the tape drive status information.
C
C  WHO  WHEN    DESCRIPTION
C  GAG  910114  Changed LFT from 4 to 5 characters and started at 6 instead
C               of 7.
C
C  INPUT:
C
      integer*2 ibuf(1)
      integer*2 lft(1)
C      - buffers of length 5 words, as returned from MATCN
C
C  OUTPUT:
C
C     ILOW - low tape sensor
C     LFT - footage counter
C     IFAS - fast speed button
C     ICAP - capstan status
C     ISTP - stop command
C     ITAC - tach lock
C     IRDY - ready status 
C 
C 
C        TPbdrsvvvv 
C     where each letter is a character with the following bits
C                   b = bits for low tape, fast speed, capstan, 
C                        and stop command 
C                   d = bits for tape lock, tach lock, and front panel (2)
C                   r = bits for ready, reset footage, and value type (2) 
C                   s = bits for decimal point 1, decimal point 2,
C                       sign, and MSB of value
C                   vvvv = four digits of value, hex.
C     Note we are only concerned with the last 8 characters
C
      ia = ia2hx(ibuf,3)
      ilow = and(ia,8)/8
      ifas = and(ia,4)/4
      icap = and(ia,2)/2
      istp = and(ia,1)
      call ichmv(lft,1,ibuf,6,5)
      itac = and(ia2hx(ibuf,4),4)/4
      irdy = and(ia2hx(ibuf,5),8)/8
C
      return
      end
