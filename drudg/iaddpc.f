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
      integer function iaddpc(ibuf,nc1,ibbc,isb,itone,ntone)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C     IADDPC puts the channel and tones on the PCALFORM= command.
C     NOTE: ibuf is modified upon return.

C History
C 971208 nrv New. Copied from iaddtr.

      include '../skdrincl/skparm.ftni'

C Called by: PROCS

C Input:
      integer*2 ibuf(*)
      integer nc1,ibbc,isb,itone(*),ntone
C     nc1 is the next char in ibuf to use
C     isb=1 for upper, =2 for lower

C Local:
      character*1 csb(2)
      integer nch,i
      integer ib2as,ichmv_ch,mcoma
      integer z8000,izero2
      data csb(1)/'u'/,csb(2)/'l'/
      data z8000/z'8000'/

      izero2 = 2+Z8000
      nch = nc1
      nch = nch + ib2as(ibbc,ibuf,nch,izero2)
      nch = ichmv_ch(ibuf,nch,csb(isb))
      nch = mcoma(ibuf,nch)
      do i=1,ntone
        nch = nch + ib2as(itone(i),ibuf,nch,izero2)
        if (i.lt.ntone) nch = mcoma(ibuf,nch)
      enddo

      iaddpc=nch

      return
      end
