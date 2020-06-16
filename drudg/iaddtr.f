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
      integer function iaddtr(ibuf,nc1,it,ichan,isb,ibit)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C     IADDTR adds a track to the TRACKFORM= command line buffer
C     NOTE: ibuf is modified upon return.

C History
C 960126 nrv Created.
C 960313 nrv Remove blanks before the track number.

      include '../skdrincl/skparm.ftni'

C Called by: PROCS

C Input:
      integer*2 ibuf(*)
      integer nc1,it,ichan,isb,ibit

C Local:
      character*1 csb(2),cbit(2)
      integer nch
      integer ib2as,ichmv_ch,mcoma
      integer z8000,izero2
      data csb(1)/'u'/,csb(2)/'l'/,cbit(1)/'s'/,cbit(2)/'m'/
      data z8000/z'8000'/

!      izero2 = 2+Z8000
      izero2=3+z8000
      nch = nc1
      nch = nch + ib2as(it,ibuf,nch,izero2)
      nch = mcoma(ibuf,nch)
      nch = nch + ib2as(ichan,ibuf,nch,izero2)
      nch = ichmv_ch(ibuf,nch,csb(isb))
      nch = ichmv_ch(ibuf,nch,cbit(ibit))
      nch = mcoma(ibuf,nch)

      iaddtr=nch

      return
      end
