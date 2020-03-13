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
      subroutine set_mic(ihead,ipass,kauto,micron,ip,tol,indxtp)
      implicit none
      integer ihead,ip(5),ipass(2),indxtp
      real*4 micron(2),tol
      logical kauto
C
C  SET_MIC: set head position(s) by micron
C
C  INPUT:
C     IHEAD - head to be positioned: 1, 2, or 3 (both)
C     IPASS(2) - pass number for positoning, indexed by head number
C                0 = use uncalibrated positions
C     KAUTO - true to adjust write head pitch
C     MICRON(2) - microns to position to, indexed by head number
C
C  OUTPUT:
C     IP - Field System return parameters
C     IP(3) = 0, if no error
C
      integer i
      real*4 volt(2)
C
      do i=1,2
        if(ihead.eq.i.or.ihead.eq.3) then
          call mic2vlt(i,ipass(i),kauto,micron(i),volt(i),ip,indxtp)
          if(ip(3).ne.0) return
        endif
      enddo
C
      call set_vlt(ihead,volt,ip,tol,indxtp)
      return
      end
