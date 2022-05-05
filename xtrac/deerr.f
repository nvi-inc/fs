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
      subroutine deerr(jbuf,ifc,ilc,off,wid,pk,bas,slp,rchi,iferr)
C 
      integer*2 jbuf(1)
C
      ifield=0
      iferr=1 
C 
C  OFFSET SIGMA 
C 
      off=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C HALF-WIDTH SIGMA
C 
      wid=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C FITTED PEAK SIGMA 
C 
      pk=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C  BASELINE TEMPERATURE SIGMA 
C 
      bas=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  BASELINE SLOPE SIGMA 
C 
      slp=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  REDUCED CHI OF THE FIT 
C 
      rchi=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
      return
      end 
