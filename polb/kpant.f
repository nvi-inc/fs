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
      logical function kpant(lut,idcb,lant,laxis,iflags,ibuf,il,lst,
     +     iobuf)

      dimension idcb(1)
      integer*2 ibuf(1),lant(1),laxis(1)
      character*(*) iobuf
      logical kpout
C
      call ifill_ch(ibuf,1,il,' ')
      inext=1
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=ichmv(ibuf,inext,lant,1,8)
      inext=ichmv_ch(ibuf,inext,'  ')
C
      inext=ichmv(ibuf,inext,laxis,1,4)
      inext=ichmv_ch(ibuf,inext,'  ')
C
      inext=inext+ihxw2as(iflags,ibuf,inext,8)
      inext=ichmv_ch(ibuf,inext,'  ')
C
      if(0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
      kpant=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
