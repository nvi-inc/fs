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
      subroutine pfrme(ibuf,lut,idcb,iobuf,lst)
C
      character*(*) iobuf
      integer*2 ibuf(1), idcb(1)
C
C  FRaMe ahead, i.e dump the picture
C
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax,
     +             xmin,xmax,ymin,ymax,
     +             rotat(2,2)
C
      iwds=iwidx/2
C
      do i=1,iwidy 
        ist=(i-1)*iwds+1
        if (kpout(lut,idcb,ibuf(ist),iwds,iobuf,lst).ne.0) stop
      enddo
C 
      return
      end 
