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
      logical function kfild(lut,iferr,ifield,irec,ipbuf)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 lfel(11),lrec(9),lin(3)
C
      data lfel   /  20,2Her,2Hro,2Hr ,2Hin,2H f,2Hie,2Hld,2H x,2Hxx,
     /             2Hx_/
C          error in field xxxx_
      data lrec   /  16,2H i,2Hn ,2Hre,2Hco,2Hrd,2H x,2Hxx,2Hx_/
C           in record xxxx_
      data lin    /   4,2H i,2Hn_/
C           in_
      kfild=.false.
      if (iferr.ge.0) return
C
      ifc=16
      ifc=ifc+ib2as(ifield,lfel(2),ifc,o'100000'+4)
      ifc=ichmv_ch(lfel(2),ifc,'_')
      call po_put_i(lfel(2),ifc)
C
      ifc=12
      ifc=ifc+ib2as(irec,lrec(2),ifc,o'100000'+4)
      ifc=ichmv_ch(lrec(2),ifc,'_')
      call po_put_i(lrec(2),ifc)
      kfild=kfmp(lut,0,lin(2),lin(1),ipbuf,0,1)

      return
      end
