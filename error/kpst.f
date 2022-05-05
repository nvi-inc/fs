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
      logical function kpst(lut,idcb,d1,d2,d3,d4,d6,d7,d8,igp,inp,
     +                      iobuf,lst,ibuf,il)
C
      double precision d1,d2,d3,d4,d6,d7,d8
      integer*2 ibuf(1)
      character*(*) iobuf
      logical kpout
      include '../include/dpi.i'
C
      s1=d1*rad2deg
      s2=d2*rad2deg
      s3=d3*rad2deg
      s4=d4*rad2deg
      s6=d6*rad2deg
      s7=d7*rad2deg
      s8=d8*rad2deg
C
      inext=1
      inext=ichmv_ch(ibuf,inext,'    ')
      inext=inext+jr2as(s1,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s2,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s3,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s4,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s6,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(igp,ibuf,inext,5)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(inp,ibuf,inext,5)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s7,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s8,ibuf,inext,-10,5,il)
C
      if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
      kpst=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
