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
      subroutine deoff(jbuf,ifc,ilc,loncor,latcor,lonoff,latoff,iqlon,
     +                 iqlat,iferr) 
C
      integer*2 jbuf(1) 
C
      real loncor,latcor,lonoff,latoff
C 
      iferr=1 
      ifield=0
C 
C  LONGITUDE LIKE COORDINATE
C 
      loncor=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C LATITUDE LIKE COORDIANE 
C 
      latcor=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C  LONGITUDE LIKE COORDIATE OFFSET
C 
      lonoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C LATITUDE LIKE COORDIANTE OFFSET 
C 
      latoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C LONGITUDE FIT QUALITY BIT 
C 
      iqlon=igtbn(jbuf,ifc,ilc,ifield,iferr)
C 
C LATITUDE FIT QUALITY BIT
C 
      iqlat=igtbn(jbuf,ifc,ilc,ifield,iferr)
C 
      return
      end 
