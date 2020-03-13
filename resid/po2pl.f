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
      subroutine po2pl(iox,ioy,ix,iy) 
C 
C  convert Object 2 PLotter 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      ioxl=max0(1,min0(iox,ixmax-ixmin+1))
      ioyl=max0(1,min0(ioy,iymax-iymin+1))
C 
      ix=ioxl-1+ixmin 
      iy=ioyl-1+iymin 
C 
      return
      end 
