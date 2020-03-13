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
      logical function kfmp(lu,ierr,imess,len,ipbuf,jerr1,jerr2)

      integer*2 imess(1),len
      integer ilen
      character*(*) ipbuf
      integer*2 lerr(8)
C
      data lerr   /  14,2Her,2Hro,2Hr ,2H  ,2H  ,2H  ,2H  /
C          error
      kfmp=.false.
      ilen = len
      if (jerr2.gt.0.and.ierr.eq.0) goto 1
      if (ierr.eq.0) return
      if (jerr1.gt.0.and.ierr.gt.0) return
      if (jerr1.eq.ierr) return
C
      kfmp=.true.
      ifc=7
      ifc=ifc+ib2as(ierr,lerr(2),ifc,o'100000'+6)
      ifc=ichmv_ch(lerr(2),ifc,' _')
      call po_put_i(lerr(2),ifc)
C
1     continue
      kfmp=.true.
      if (ilen.le.0) goto 2
      call po_put_i(imess,ilen)
C
2     continue
      call po_put_c(ipbuf)
C
      return
      end
