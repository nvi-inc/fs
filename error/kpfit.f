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
      logical function kpfit(lu,idcbo,ierr,rchi,rlnnr,rltnr,nfree,
     + feclon,feclat,iftry,iflags,iobuf,lst,ibuf,il)
C
      integer*2 ibuf(1)
      character*(*) iobuf
      logical kpout
      include '../include/dpi.i'
C
      inext=1
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(ierr,ibuf,inext,4)
      inext=ichmv_ch(ibuf,inext,'     ')
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+jr2as(rchi,ibuf,inext,-6,3,il)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+jr2as(rlnnr,ibuf,inext,-6,3,il)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+jr2as(rltnr,ibuf,inext,-6,3,il)
      inext=ichmv_ch(ibuf,inext,'       ')
      inext=inext+ib2as(nfree,ibuf,inext,4)
      inext=ichmv_ch(ibuf,inext,'    ')
      inext=inext+jr2as(sngl(feclon*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(sngl(feclat*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(iftry,ibuf,inext,4)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(iflags,ibuf,inext,6)
      inext=ichmv_ch(ibuf,inext,'    ')
C
      if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
      kpfit=kpout(lu,idcbo,ibuf,inext,iobuf,lst)
C
      return
      end 
