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
      SUBROUTINE unpvh(IBUF,ILEN,IERR,LIDHOR,NHOR,AZH,ELH)
C
C     UNPVH unpacks a record containing horizon mask data.
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer containing the record
C     ILEN  - length of IBUF in words
C
C  OUTPUT:
      integer ierr
      integer*2 lidhor
      integer nhor
C     IERR    - error return, 0=ok, -100-n=error in nth field
C     LIDHOR - positon ID, 2 characters
C     NHOR - number of az,el pairs
      REAL*4 AZH(*), ELH(*)
C            - az,el pairs defining horizon mask, DEGREES
C
C  LOCAL:
      real*8 R,DAS2B
      integer ich,nc,ic1,ic2,nch,idumy
      integer jchar,ichmv
C
C  Modifications:
C  880707  NRV  Created
C  881101  NRV  ADDED CATALOG INFO
C  891215  NRV  Removed catalog info call, including PCOUNT
C  930225  nrv  implicit none
C 960201 nrv Check range of az,el
C 960404 nrv Remove checks for range because this same routine is
C            used for coordinate masks also.
C
C
C     Start the unpacking with the first character of the buffer.
C
      ICH = 1
C
C     The site ID.
 
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.NE.2) THEN
        IERR = -101
        RETURN
      END IF  !
      call char2hol(' ',LIDHOR,1,2)
      IDUMY = ICHMV(LIDHOR,1,IBUF,IC1,2)
C
C     Horizon mask az,el pairs
C
      NHOR = 0
1     CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IF (IC1.EQ.0) GOTO 2
      NC = IC2-IC1+1
      IF (NC.EQ.1.AND.JCHAR(IBUF,IC1).EQ.OCAPX) GOTO 2
      R = DAS2B(IBUF,IC1,NC,IERR)
      IF (IERR.NE.0) THEN
        IERR = -101-NHOR*2
        RETURN
      ENDIF
C     if (r.lt.0.or.r.gt.360.0) then ! out of range
C       ierr=-101-nhor*2
C       return
C     endif
      if (nhor.eq.max_hor) then ! too many
        ierr=-99
        return
      endif
      NHOR = NHOR + 1
      AZH(NHOR) = R
C  If az entries are not in ascending order, error
      if (nhor.gt.1.and.azh(nhor).le.azh(nhor-1)) then
        ierr=-201-nhor*2
        return
      endif
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) ! get matching el
      IF (IC1.EQ.0) then ! no matching el
        ierr=-103
        return
      endif
      NC = IC2-IC1+1
      IF (NC.EQ.1.AND.JCHAR(IBUF,IC1).EQ.OCAPX) GOTO 2
      R = DAS2B(IBUF,IC1,NC,IERR)
      IF (IERR.NE.0) THEN
        IERR = -102-NHOR*2
        RETURN
      ENDIF
C     if (r.lt.0.or.r.gt.90.0) then ! out of range
C       ierr=-102-nhor*2
C       return
C     endif
C     ELH(NHOR) = R*PI/180.0
      ELH(NHOR) = R
      GOTO 1
2     CONTINUE !done with horizon mask
C
      RETURN
      END
