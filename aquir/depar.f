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
      subroutine depar(jbuf,ifc,ilc,lset,iwset,lter,iwter,elmax,
     +                 mprc,iferr,isrcwt,isrcld)
C
      include '../include/dpi.i'
C
      integer*2 jbuf(1),lset(mprc),lter(mprc)
C
C
      iferr=1
      ifield=0
C
C Setup procedure
C
      call gtchr(lset,1,mprc*2,jbuf,ifc,ilc,ifield,iferr)
C
C Setup procedure wait
C
      iwset=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C Termination procedure
C
      call gtchr(lter,1,mprc*2,jbuf,ifc,ilc,ifield,iferr)
C
C Termination procedure wait
C
      iwter=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C maximum Elevation
C
      elmax=gtrel(jbuf,ifc,ilc,ifield,iferr)*RPI/180.
C
C source wait
C
      isrcwt=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C source lead time
C
      isrcld=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
      return
      end
