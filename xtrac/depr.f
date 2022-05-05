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
      subroutine depr(jbuf,ifc,ilc,prlon,prlat,praz,prel,iferr) 
C
      integer*2 jbuf(1) 
C 
      ifield=0
      iferr=1 
C 
C  PREDICTED LONGITUDE LIKE COORDINATE
C 
      prlon=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C            LATITUDE LIKE COORDINATE 
C 
      prlat=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  PREDICTED AZIMUTH
C 
      praz=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C            ELEVATION
C 
      prel=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
      return
      end 
