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
      SUBROUTINE raded(RA,DEC,HA,IRAH,IRAM,RAS,
     .LDSIGN,IDECD,IDECM,DECS,
     .LHSIGN,IHAH,IHAM,HAS)
C
C     RADED converts ra,dec,ha in radians to the hms, dms, hms.
C
      implicit none
      include "../skdrincl/constants.ftni"
C  INPUT:
      real*8 RA,DEC,HA
C     RA, DEC, HA - in radians
C
C  OUTPUT:
      integer irah,iram,idecd,idecm,ihah,iham
      integer ldsign,lhsign
      real*4 ras,decs,has
C     IRAH,IRAM,RAS - hms for ra
C     LDSIGN,IDECD,IDECM,DECS - sign, dms for dec
C     LHSIGN,IHAH,IHAM,HAS - sign, hms for hour angle
C
C  LOCAL:
      real*8 H,D
C
C  CONSTANTS:

C
C     1. First convert the RA.
C
      H = RA*12.D0/PI
      IRAH = H
      IRAM = (H-IRAH)*60.D0
      RAS = (H-IRAH-IRAM/60.D0)*3600.D0
      IF  (RAS.GE.60.D0) THEN  !
        RAS=RAS-60.D0
        IRAM=IRAM+1
      END IF  !
      IF  (IRAM.GE.60) THEN  !
        IRAM=IRAM-60
        IRAH=IRAH+1
      END IF  !
      IF (IRAH.GE.24) IRAH=IRAH-24
C
C
C     2. Next the declination.
C
      D = DABS(DEC)*180.D0/PI
      IDECD = D
      IDECM = (D - IDECD)*60.D0
      DECS = (D-IDECD-IDECM/60.D0)*3600.D0
      IF  (DECS.GE.60.D0)  THEN  !
        DECS=DECS-60.D0
        IDECM=IDECM+1
      END IF  !
      IF  (IDECM.GE.60) THEN  !
        IDECM=IDECM-60
        IDECD=IDECD+1
      END IF  !
C
      call char2hol ('+ ',LDSIGN,1,2)
      IF (DEC.LT.0.D0) call char2hol('- ',LDSIGN,1,2)
C
C
C     3. Finally the hour angle.
C
      H = DABS(HA)*12.D0/PI
      IHAH = H
      IHAM = (H - IHAH)*60.D0
      HAS = (H - IHAH - IHAM/60.D0)*3600.D0
      call char2hol('  ',LHSIGN,1,2)
      IF  (HAS.GE.60.D0)  THEN  !
        HAS=HAS-60.D0
        IHAM=IHAM+1
      END IF  !
      IF  (IHAM.GE.60)  THEN  !
        IHAM=IHAM-60
        IHAH=IHAH+1
      END IF  !
C
      IF (HA.LT.0.D0) call char2hol('- ',LHSIGN,1,2)
      RETURN
      END
