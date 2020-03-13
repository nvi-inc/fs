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
      subroutine iw2ma(ibuf,ispeed,idir,ihead,jdur)
      implicit none
      integer ispeed,idir,ihead
      integer*2 ibuf(4)
      integer*4 jdur
C
C  IW2MA: build inchworm buffer for MAT
C
C  INPUT:
C     ISPEED: speed, 0=slow or 1=fast
C     IDIR: direction, 0=in or 1=out
C     IHEAD: head, 1 or 2
C     JDUR: move duration, 0 to 65535 (units 40 usecs)
C
C  OUTPUT:
C     IBUF: hollerith buffer holding eight characters for MAT
C
      integer inext,ichmv,ihx2a,ih22a,ibyte,ichmv_ch
c     integer idum
C
      inext=1
      inext=ichmv_ch(ibuf,inext,'0')
      inext=ichmv(ibuf,inext,ihx2a(ispeed),2,1)
      inext=ichmv(ibuf,inext,ihx2a(idir),2,1)
      inext=ichmv(ibuf,inext,ihx2a(ihead-1),2,1)
C
      ibyte=jdur/256
c     idum=ichmv(ibyte,2,jdur,3,1)
      inext=ichmv(ibuf,inext,ih22a(ibyte),1,2)
      ibyte=jdur
c     idum=ichmv(ibyte,2,jdur,4,1)
      inext=ichmv(ibuf,inext,ih22a(ibyte),1,2)
C
      return
      end
