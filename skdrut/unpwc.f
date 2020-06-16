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
      SUBROUTINE unpwc(IBUF,ILEN,IERR,
     .LRAHMS,IRAH,IRAM,RAS,RARAD,
     .LDSIGN,LDCDMS,IDECD,IDECM,DECS,DECRAD,
     .EPOCH,ICH)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     UNPWC unpacks celestial source information from source entry record.
C           This routine is a utility for unpso.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
C
C  HISTORY:
C    NRV  891110  Modified UNPWC for new catalog routines
C    nrv  930225  implicit none

C Called by: UNPSO
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,ich
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C     ICH   - characters processed so far in IBUF
C
C  OUTPUT:
      integer ierr,iram,irah,idecd,idecm
      integer*2 ldsign
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C   Celestial Source Info:
      integer*2 LRAHMS(8)
C          - right ascension, in form hhmmss.ssssssss
C     IRAH,IRAM - right ascension hours&minutes, in binary
      double precision RAS
C           - seconds field of right ascension
      double precision RARAD
C           - right ascension, in radians
C     LDSIGN - sign of the declination, + or -
      integer*2 LDCDMS(7)
C           - declination, in form ddmmss.sssssss
C     IDECD,IDECM - declination degrees&minutes, in binary
      double precision DECS
C           - declination seconds field
      double precision DECRAD
C           - declination, in radians
C     EPOCH - epoch of RA and DEC
      real epoch
C
C  SUBROUTINES CALLED: LNFCH UTILITIES
C
C  LOCAL:
C
      double precision DAS2B
      integer ic1,ic2,id,idumy,isign,numc2
      integer iscnc,ias2b,ichmv,jchar ! functions
      real r
C
C  INITIALIZED:
C
      numc2 = 2+o'40000'+o'400'*2
C
C     Right ascension.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IRAH = IAS2B(IBUF,IC1,IC2-IC1+1)
      IF  (IRAH.LT.0.OR.IRAH.GT.24) THEN  !
        IERR = -103
        RETURN
      END IF  !
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IRAM = IAS2B(IBUF,IC1,IC2-IC1+1)
      IF  (IRAM.LT.0.OR.IRAM.GT.60) THEN  !
        IERR = -104
        RETURN
      END IF  !
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      RAS = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (IERR.LT.0.OR.RAS.GT.60.0) THEN  !
        IERR = -105
        RETURN
      END IF  !
C
      RARAD = (IRAH*3600.D0+IRAM*60.D0+RAS)*PI/43200.D0
C                   Compute RA in radians
      CALL IFILL(LRAHMS,1,16,oblank)
C                   First clear out the ASCII returned RA
      CALL IB2AS(IRAH,LRAHMS,1,numc2)
C                   Put back the RA, leading zeros attached
      CALL IB2AS(IRAM,LRAHMS,3,numc2)
C                   The minutes, with leading zeros
      CALL IB2AS(IDINT(RAS),LRAHMS,5,numc2)
C                   The integral part of seconds, with leading zeros
      ID = ISCNC(IBUF,IC1,IC2,ODOT)
C                   Find the decimal point in the seconds, if any
      IF (ID.GT.0) IDUMY = ICHMV(LRAHMS,7,IBUF,ID,MIN0(IC2-ID+1,8))
C                   Finally move in the decimal point and fractional seconds
C
C
C     Declination.
C
      ISIGN = +1
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IF  (JCHAR(IBUF,IC1).EQ.OMINUS) THEN  !"- sign"
        IC1 = IC1 + 1
        ISIGN = -1
      END IF  !"- sign"
      IDECD = IAS2B(IBUF,IC1,IC2-IC1+1)
      IF  (IDECD.LT.0.OR.IDECD.GT.90) THEN  !
        IERR = -106
        RETURN
      END IF  !
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IF  (JCHAR(IBUF,IC1).EQ.OMINUS) THEN  !"- sign"
        IC1 = IC1 + 1
        ISIGN = -1
      END IF  !"- sign"
      IDECM = IAS2B(IBUF,IC1,IC2-IC1+1)
      IF  (IDECM.LT.0.OR.IDECM.GT.60) THEN  !
        IERR = -107
        RETURN
      END IF  !
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IF  (JCHAR(IBUF,IC1).EQ.OMINUS) THEN  !"- sign"
        IC1 = IC1 + 1
        ISIGN = -1
      END IF  !"- sign"
      DECS = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (IERR.LT.0.OR.DECS.GT.60.0D0) THEN  !
        IERR = -108
        RETURN
      END IF  !
C
      DECRAD = (IDECD*3600.D0+IDECM*60.D0+DECS)*PI/648000.D0
C                   Compute declination in radians
      CALL IFILL(LDCDMS,1,14,oblank)
C                   First clear out the ASCII returned DC
      CALL IB2AS(IDECD,LDCDMS,1,numc2)
C                   Put back the degrees, leading zeros attached
      CALL IB2AS(IDECM,LDCDMS,3,numc2)
C                   The minutes, with leading zeros
      CALL IB2AS(IDINT(DECS),LDCDMS,5,numc2)
C                   The integral part of seconds, with leading zeros
      ID = ISCNC(IBUF,IC1,IC2,ODOT)
C                   Find the decimal point in the seconds, if any
      IF (ID.GT.0) IDUMY = ICHMV(LDCDMS,7,IBUF,ID,MIN0(IC2-ID+1,7))
C                   Finally move in the decimal point and fractional seconds
      call char2hol('+ ',LDSIGN,1,2)
      IF  (ISIGN.EQ.-1) THEN  !
        DECRAD = -DECRAD
        call char2hol('- ',LDSIGN,1,2)
      END IF  !
C
C
C     The epoch of position.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      R = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (R.LE.0.0.OR.R.LT.1800.0.OR.R.GT.3500.0) THEN  !
        IERR = -109
        RETURN
      END IF  !
      EPOCH = R
C
C
C      Di-da-da-di-da-da-di that's all folks!
C
      RETURN
      END
