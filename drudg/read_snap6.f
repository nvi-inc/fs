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
      subroutine read_snap6(cbuf,crack,creca,crecb,ierr)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C Read the sixth comment line of a SNAP file.
C Example:
C " Rack=VLBAG     Recorder A=VLBA      Recorder B=none

C 991103 nrv Created to scan for equipment.

C Called by: LSTSUM

C Input
      character*(*) cbuf
C Output
      character*8 crack,creca,crecb
      integer ierr

C Local
      integer ic1,ich,ilen
!  functions
      integer trimlen

C Convert to hollerith, find length.
      ilen=trimlen(cbuf)
      crack = ' '
      creca = ' '
      crecb = ' '

C Find up to three '=' and take the name following.

      ierr=-1
      ich = index(cbuf,'=')
      if (ich.eq.0) return
      ic1 = ich + index(cbuf(ich:),' ')
      if (ic1.eq.0) return
      crack = cbuf(ich+1:ic1)
      ich = ic1 + index(cbuf(ic1:),'=') - 1
      if (ich.eq.0) return
      ic1 = ich + index(cbuf(ich:),' ')
      if (ic1.eq.0) return
      creca = cbuf(ich+1:ic1)
      ich = ic1 + index(cbuf(ic1:),'=') - 1
      if (ich.eq.0) return
      ic1 = ich + index(cbuf(ich:),' ')
      if (ic1.eq.0) return
      crecb = cbuf(ich+1:ic1)

      ierr=0

      return
      end
