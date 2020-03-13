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
      subroutine pplpt(ibuf,x,y)
C
      integer*2 ibuf(1),iold
      integer jchar,ixy
C 
      real x,y
C
C  PLot PoinT 
C 
      call pv2ob(x,y,iox,ioy) 
      call po2pl(iox,ioy,ix,iy) 
      call pp2ch(ix,iy,ixy) 
C 
      iold=jchar(ibuf,ixy)
      idiff=0 
C 
      if (iold.eq.ichar(' ')) goto 50
      if (iold.eq.ichar('-')) goto 50
      if (iold.eq.ichar('|')) goto 50
C 
      idiff=iold-48 
      if (iold.ge.49.and.iold.le.57) goto 50
      idiff=iold-64+9 
      if (iold.ge.65.and.iold.le.90) goto 50
      stop 2
C
50    continue
      idiff=min0(idiff+1,35)
      inew=idiff+48
      if (inew.gt.57) inew=idiff-9+64
C
      idum=ichmv(ibuf,ixy,inew,1,1)
C
      return
      end
