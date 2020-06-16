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
	SUBROUTINE bbsyn(iy,ix,fr)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C  bbsyn appends the appropriate bbysnth to the buffer
C  for writing the bbsyn frequencies
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/freqs.ftni'
C
C   HISTORY:
C  WHO   WHEN   WHAT
C  gag   900809 CREATED
C  NRV   910524 Added frequency to calling sequence
C  nrv   930412 implicit none
C
C  INPUT:
	integer iy  ! location in buffer ibuf
	integer ix  ! video converter number
	real fr     ! BBC frequency
C
C  OUTPUT:
C
C     CALLED BY: vlbah
C     CALLED: char2hol, ib2as, ir2as
C
C  LOCAL
	integer Z8000
      integer ib2as,ir2as ! functions
C
C  INITIALIZED
	data Z8000/Z'8000'/
C

C  Form the information inside parenthesis in the buffer.

	call char2hol('(',ibuf,iy,iy+1)
	iy = iy+1

C      if (ix.le.9) then
	  iy = iy + ib2as(ix,ibuf,iy,Z8000+2)
C        iy = iy + 1
C      else
C        idum = ib2as(ix,ibuf,iy,2)
C        iy = iy + 2
C      end if

	call char2hol(',',ibuf,iy,iy+1)
	iy = iy + 1

C      if (fr.lt.1000.0) then
	  iy = iy + ir2as(fr,ibuf,iy,7,2)
C        iy = iy + 6
C      else
C        idum = ir2as(fr,ibuf,iy,7,2)
C        iy = iy + 7
C      end if

	call char2hol(')',ibuf,iy,iy+1)
	iy = iy + 1
C
	RETURN
	END
