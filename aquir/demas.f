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
      subroutine demas(jbuf,ifc,ilc,azar,elar,imask,imsmax,iferr)
C
      real azar(1),elar(1)
      integer*2 jbuf(1)
C
      include '../include/dpi.i'
C
      iferr=1
      ifield=0
C
C AZIMUTH
C
      i=-imask
1     continue
      i=i+1
      az=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      if (iferr.lt.0) then
        iferr=0
        imask=1-i
        return
      else if (i.gt.imsmax) then
        call put_stderr('too many elevation mask azimuths\n'//char(0))
        stop
      endif
      azar(i)=az
C
C Elevation
C
      elar(i)=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      if (iferr.lt.0.and.i.lt.2) then
        call put_stderr(
     &        'minimum of two azimuths in elevation mask\n'//char(0))
        stop
      else if (iferr.lt.0) then
        iferr=-iferr
        imask=i
        return
      endif
      goto 1
C
c     return
      end
