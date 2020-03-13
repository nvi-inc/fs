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
      logical function kpdat(lut,idcb,kuse,ar1,ar2,ar3,ar4,ar5,
     +                       mc,iobuf,lst,ibuf,il)
C
      dimension idcb(1)
      integer*2 ibuf(1)
      character*(*) iobuf
C
      double precision ar1,ar2
      logical kpout,kuse
      include '../include/dpi.i'
C
      inext=1
      if (.not.kuse) inext=ichmv_ch(ibuf,inext,' 0  ')
      if (kuse) inext=ichmv_ch(ibuf,inext,' 1  ')
      inext=inext+jd2as(ar1*rad2deg,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jd2as(ar2*rad2deg,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(sngl(ar3*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(sngl(ar4*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(sngl(ar5*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
C
      if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
      kpdat=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
