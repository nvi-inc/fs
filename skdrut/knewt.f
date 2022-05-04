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
	LOGICAL FUNCTION KNEWT(IFT,IPAS,IPASP,IDIR,IDIRP,IFTOLD)
C KNEWT RETURNS TRUE IF THIS RUN WOULD START A NEW TAPE
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
      include '../skdrincl/skparm.ftni'
C
C 960819 nrv change final check for IPASP to .LT. 0 because 0 is
C            a valid S2 pass number
C 000107 nrv Allow a 100-ft difference before declaring a new tape.
C 2003July08 JMGipson. changed to 150

C Input:
      integer ift,ipas,ipasp,idir,idirp,iftold
      integer ift_tol
      parameter (ift_tol=150)

      KNEWT =
     >   IPAS.LT.IPASP.OR.
     .  (IPAS.EQ.IPASP.AND.IDIR.NE.IDIRP).OR.
     .  (IPAS.EQ.IPASP.AND.((IDIR.EQ.+1.AND.IFT.LT.(IFTOLD-ift_tol))
     .   .OR.(IDIR.EQ.-1.AND.IFT.GT.(IFTOLD+ift_tol))))
      IF (IPASP.LT.0) KNEWT=.TRUE.
C
      RETURN
      END
