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
      subroutine deorg(jbuf,ifc,ilc,haoff,decoff,azoff,eloff,xoff,yoff, 
     +                 iferr) 
C
      integer*2 jbuf(1) 
C 
      ifield=0
      iferr=1 
C 
C HA OFFSET 
C 
      haoff=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C DEC 
C 
      decoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C AZIMUTH 
C 
      azoff=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C ELEVATION 
C 
      eloff=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C X 
C 
      xoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C Y 
C 
      yoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
      return
      end 
