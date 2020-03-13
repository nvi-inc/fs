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
      subroutine pv2ob(x,y,iox,ioy) 
C 
      real x,y
C  convert Virtual 2 OBject 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      xl=amax1(xmin,amin1(x,xmax))
      yl=amax1(ymin,amin1(y,ymax))
C 
      xratio=(xl-xmin)/(xmax-xmin)-0.5
      yratio=(yl-ymin)/(ymax-ymin)-0.5
C 
      xrot=rotat(1,1)*xratio+rotat(1,2)*yratio+0.5
      yrot=rotat(2,1)*xratio+rotat(2,2)*yratio+0.5
C 
      iox=xrot*float(ixmax-ixmin)+1.5 
      ioy=yrot*float(iymax-iymin)+1.5 
C 
      return
      end 
