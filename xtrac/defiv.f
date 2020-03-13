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
      subroutine defiv(jbuf,ifc,ilc,laxis,nrep,npts,step,intp,ldev,cal, 
     +                 freq,iferr)
C
      integer*2 jbuf(1),laxis(1),ldev(2)
C 
      iferr=1 
      ifield=0
C 
C  AXIS TYPE
C 
      call gtchr(laxis,1,4,jbuf,ifc,ilc,ifield,iferr) 
C 
C  NUMBER OF REPTITIONS 
C 
      nrep=igtbn(jbuf,ifc,ilc,ifield,iferr) 
C 
C  NUMBER OF POINTS 
C 
      npts=igtbn(jbuf,ifc,ilc,ifield,iferr) 
C 
C  STEP SIZE
C 
      step=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C INTEGRATION PERIOD
C 
      intp=igtbn(jbuf,ifc,ilc,ifield,iferr) 
C 
C DETECTOR DEVICE 
C 
      call gtchr(ldev,1,4,jbuf,ifc,ilc,ifield,iferr)
C 
C CALIBRATION NOISE TEMP
C 
      cal=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  FREQUENCY
C 
      freq=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
      return
      end 
