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
      subroutine incsm(lonsum,lonrms,lnofr,latsum,latrms,ltofr,
     +                 dirms,distr,np,lut)
C
      double precision lonsum,lonrms,latsum,latrms,dirms
      double precision dim1,dri,dlnof,dltof,ddisr
      real lnofr,ltofr,distr
C
      dim1=dble(float(np-1)/float(np))
      dri=1.0d0/dble(float(np))
      dlnof=dble(lnofr)
      dltof=dble(ltofr)
      ddisr=dble(distr)
      lonsum=lonsum*dim1+dlnof*dri
      latsum=latsum*dim1+dltof*dri
      lonrms=lonrms*dim1+dlnof*dlnof*dri
      latrms=latrms*dim1+dltof*dltof*dri
      dirms=dirms*dim1+ddisr*ddisr*dri
C
      return
      end
