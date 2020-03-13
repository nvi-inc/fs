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
      subroutine frmaux(ibuf,iposn,ipas)
      implicit none
      integer*2 ibuf(1)
      integer iposn,ipas
C
C FRMAUX: FORMAT AUX DATA INTO BUFFER
C
C INPUT:
C   IPOSN: position of write head in microns
C   IPAS: pass number of write head
C         odd, implies forward pass (-1 is odd)
C         even, implies reverse pass (-2 is even)
C         0, implies no calibration
C
C OUTPUT:
C   IBUF: output hollerith aux data field, 12 characters
C         <XXwxwxyzyzFF>
C         where XX is hex FF for forward calibration
C                         FE for reverse calibration
C                         FD for no      calibration
C         wxyz encodes the micron position
C           0000-3999 are positive positions
C           4000-7999 are negative positions as 4000+abs(position)
C         FF is hex FF
C
      integer iof,idumm1,ib2as,ichmv,ichmv_ch
      integer*2 ixx
C
      iof=min(abs(iposn),3999)    !limit offset to 3999
      if(iposn.lt.0) iof=iof+4000
      idumm1 = ib2as(iof,ibuf,5,o'40000'+o'400'*4+4)
      if(ipas.eq.0) then
        call char2hol('fd',ixx,1,2)
      else if(mod(ipas,2).eq.0) then
        call char2hol('fe',ixx,1,2)
      else
        call char2hol('ff',ixx,1,2)
      endif
C
      idumm1 = ichmv(ibuf, 1,ixx ,1,2)
      idumm1 = ichmv(ibuf, 3,ibuf,5,2)
      idumm1 = ichmv(ibuf, 9,ibuf,7,2)
      idumm1 = ichmv_ch(ibuf,11,'ff')
C
      return
      end
