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
      SUBROUTINE SELEV(LINSTQ,luscn,ludsp)
C
C     SELEV reads/writes station elevation limits
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
C
C  INPUT:
      integer*2 LINSTQ(*)
      integer luscn,ludsp
C
C  COMMON:
C     include 'skcom.ftni'
      include '../skdrincl/statn.ftni'
C
C  Calls: gtfld,  ifill, wrerr

! functions
      real*8 DAS2B
      integer i2long,ichmv,jchar !functions
      integer igetstatnum2
C  LOCAL
      integer*2 LKEYWD(12)
      integer ich,ic1,ic2,nch,i,idummy,ierr,istn
      real*4 el,val

      character*24 ckeywd
      equivalence (lkeywd,ckeywd)

C
C MODIFICATIONS:
C   880314 NRV DE-COMPC'D
C   930225 nrv implicit none
C   950405 nrv Use 2-letter station codes for listings.
c   950411 nrv Call IGTST2 for input of 2-letter codes
C 951017 nrv Fixed gtfld call to remove linstq
C 960415 nrv Do not return on initial error, find all. 
C
C
C     1. Check for some input.  If none, write out current.
C
      ICH = 1
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN  !no input
        IF  (NSTATN.LE.0) THEN  !no stations selected
          write(luscn,'("SELVE00 Error - Select stations first.")')
          RETURN
        END IF  !no stations selected
        WRITE(LUDSP,' (" ID  STATION  EL LIMIT(deg)")')
        DO  I=1,NSTATN
          EL = STNELV(I)*rad2deg
          WRITE(LUDSP,"(1X,A2,2X,A,1X,F5.1)") cpoCOD(I),cSTNNA(I),EL
        END DO  !
        RETURN
      END IF  !no input
C
C
C     2. Something is specified.  Get each station/elevation combination.
C
      DO WHILE (IC1.NE.0) !more decoding
        NCH = IC2-IC1+1
        CALL IFILL(LKEYWD,1,20,oblank)
        IDUMMY = ICHMV(LKEYWD,1,LINSTQ(2),IC1,MIN0(NCH,20))
        IF  (JCHAR(LINSTQ(2),IC1).EQ.OUNDERSCORE) THEN  !all stations
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          IF  (IC1.EQ.0) THEN  !no matching elevation
            write(luscn,'("SELEV05 Error - Specify an elevation.")')
            RETURN
          END IF  !no matching elevation
          VAL = DAS2B(LINSTQ(2),IC1,IC2-IC1+1,IERR)
          IF  (IERR.LT.0.OR.VAL.LT.0.0.OR.VAL.GT.90.0) THEN  !invalid
            write(luscn,'("SELEV06 Error - Invalid elevation.")')
            RETURN
          END IF  !invalid
          DO  I = 1,NSTATN
            STNELV(I) = VAL*deg2rad
          END DO
          RETURN
        END IF  !all stations
        istn=igetstatnum2(ckeywd(1:2))
        if (istn.le.0) then
          write(luscn,9901) ckeywd
9901      format('SELEV01 - Invalid station name: ',a2)
C         skip over matching elevation and get next station name
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
        else ! valid
C         get matching elevation
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          IF  (IC1.EQ.0) THEN  !no matching elevation
            write(luscn,9902) lkeywd(1)
9902        format('SELEV02 - No matching elevation for station ',a2)
            RETURN
          END IF  !no matching elevation
          VAL = DAS2B(LINSTQ(2),IC1,IC2-IC1+1,IERR)
          IF  (IERR.LT.0.OR.VAL.LT.0.0.OR.VAL.GT.90.0) THEN  !invalid
            write(luscn,9903) lkeywd(1)
9903        format('SELEV03 - Invalid elevation for ',a2)
          else ! valid
            STNELV(ISTN) = VAL*deg2rad
C           get next station name
            CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          endif ! invalid/valid elevation
        endif ! invalid/valid station name
      END DO  !more decoding
C
      RETURN
      END

