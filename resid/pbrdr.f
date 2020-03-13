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
      subroutine pbrdr(ibuf)
C
      integer*2 ibuf(1) 
      integer*2 ipipe,idash
C 
C  draw BoRDeR
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
c
      data ipipe/2H||/
      data idash/2H--/
C 
      do i=iymin,iymax 
        call pppnt(ibuf,ixmin,i,ipipe) 
        call pppnt(ibuf,ixmax,i,ipipe) 
      enddo
C 
      do i=ixmin,ixmax 
        call pppnt(ibuf,i,iymin,idash) 
        call pppnt(ibuf,i,iymax,idash) 
      enddo
C 
      return
      end 
