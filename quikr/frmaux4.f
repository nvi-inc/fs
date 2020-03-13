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
      subroutine frmaux4(ibuf,posn)
      implicit none
      integer*2 ibuf(1)
      real*4 posn(2)
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
C         <abcdwxyz>
C         abcd encodes the micron position head 1
C         wxyz encodes the micron position head 2
C           0000-3999 are positive positions
C           4000-7999 are negative positions as 4000+abs(position)
C
      integer iof1,iof2,idumm1,ib2as,iposn(2)
C
      iposn(1)=nint(posn(1))
      iposn(2)=nint(posn(2))
      iof1=min(abs(iposn(1)),3999)    !limit offset to 3999
      iof2=min(abs(iposn(2)),3999)    !limit offset to 3999
      if(iposn(1).lt.0) iof1=iof1+4000
      if(iposn(2).lt.0) iof2=iof2+4000
      idumm1 = ib2as(iof1,ibuf,1,o'40000'+o'400'*4+4)
      idumm1 = ib2as(iof2,ibuf,5,o'40000'+o'400'*4+4)
C
      return
      end
