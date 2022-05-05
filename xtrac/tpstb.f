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
      subroutine tpstb(lut,idcb,avglon,avglat,rmslon,rmslat,
     .dirms,inp,igp,iobuf,lst,ibuf,il)
C
      integer*2 ibuf(1)
      integer*2 idcb(1)
      integer lut,inp,igp,lst,il
      integer ichmv_ch
      integer jr2as,ib2as
      real avglon,avglat,rmslon,rmslat,dirms
      character*(*) iobuf
      logical kpout,kpret
C
      call ifill_ch(ibuf,1,100,' ')
      inext=1
      inext=ichmv_ch(ibuf,inext,'     ')
C
      inext=inext+jr2as(avglon,ibuf,inext,-8,4,il)
      inext=ichmv_ch(ibuf,inext,' ')
C 
      inext=inext+jr2as(rmslon,ibuf,inext,-8,4,il)  
      inext=ichmv_ch(ibuf,inext,' ')
C 
      inext=inext+jr2as(avglat,ibuf,inext,-7,4,il)  
      inext=ichmv_ch(ibuf,inext,' ')
C 
      inext=inext+jr2as(rmslat,ibuf,inext,-7,4,il)  
      inext=ichmv_ch(ibuf,inext,' ')
C 
      inext=inext+jr2as(dirms,ibuf,inext,-6,4,il) 
      inext=ichmv_ch(ibuf,inext,' ')
C 
      inext=inext+ib2as(igp,ibuf,inext,3) 
      inext=ichmv_ch(ibuf,inext,' ')
C 
      inext=inext+ib2as(inp,ibuf,inext,3) 
      inext=ichmv_ch(ibuf,inext,' ')
C
      if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
      kpret=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
