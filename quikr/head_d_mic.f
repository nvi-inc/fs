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
      subroutine head_d_mic(ihead,micmov,tmove,ispdhd,ip,indxtp)
      integer ihead,ispdhd,ip(5),indxtp
      real*4 tmove
      real*4 micmov,fast,slow
C
C  HEAD_D_MIC: move a head a delta in microns
C
C  INPUT:
C     IHEAD: Head index 1 or 2
C     MICMOV: distance to move
C
C  OUTPUT:
C     TMOVE - seconds the head moved for
C     IP - Field System Parameters
C     IP(3) = 0 if no errors
C
      include '../include/fscom.i'
C
      integer idir
      real*4 timmov
C
      if(micmov.lt.0) then
        idir=1   ! out, burleighs call it forward
        fast=fastfw(ihead,indxtp)
        slow=slowfw(ihead,indxtp)
      else
        idir=0   ! in, burleighs call it reverse
        fast=fastrv(ihead,indxtp)
        slow=slowrv(ihead,indxtp)
      endif
C
      timmov=abs(micmov)/slow
      ispdhd=0
      if(timmov.gt.1.0.or..not.kiwslw_fs(indxtp)) then
        timmov=abs(micmov)/fast
        ispdhd=1
      endif
C
      tmove=min(timmov,1.0)
      call head_move(ihead,idir,ispdhd,tmove,ip,indxtp)
      return
      end
