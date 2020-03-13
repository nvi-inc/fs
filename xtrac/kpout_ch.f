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
      logical function kpout_ch(lut,idcb,cbuf,iobuf,lst)
C
      integer idcb(1),lut
      character*(*) iobuf,cbuf
      integer*2 iarr(128)
      logical kpout
C
      if(len(cbuf).gt.256) stop 999
      call char2hol(cbuf,iarr,1,len(cbuf))
      kpout_ch=kpout(lut,idcb,iarr,len(cbuf),iobuf,lst)
      return
      end
