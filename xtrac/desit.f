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
      subroutine desit(jbuf,ifc,ilc,lant,slon,slat,adiam,lsaxis,
     +                 imodel,fpver,fsver,iferr)
C
      integer*2 jbuf(1),lant(1),lsaxis(1)
C 
      ifield=0
      iferr=1 
C 
C SITE ANTENNA
C 
      call gtchr(lant,1,8,jbuf,ifc,ilc,ifield,iferr)
C 
C LONGTUDE
C 
      slon=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C LATITIUDE 
C 
      slat=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C ADIAM 
C 
      adiam=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C AXIS TYPE 
C 
      call gtchr(lsaxis,1,4,jbuf,ifc,ilc,ifield,iferr)
C 
C MODEL NUMBER
C 
      imodel=igtbn(jbuf,ifc,ilc,ifield,iferr) 
C 
C FIVPT VERSION 
C 
      fpver=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C FS VERSION
C 
      fsver=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
      return
      end 
