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
C@RAS2B
      REAL*4 FUNCTION RAS2B(IAS,IC1,NCH,IERR)
C
C     THIS FUNCTION CONVERTS AN ASCII STRING TO REAL
C
      implicit none

C  INPUT PARAMETERS:
      integer*2 IAS(*)
      integer ic1,nch
C       INPUT STRING WITH ASCII CHARACTERS
C     IC1 - FIRST CHARACTER TO USE IN IAS
C     NCH - NUMBER OF CHARACTERS TO CONVERT
C
C  OUTPUT:
      integer ierr
C     IERR - ERROR RETURN, 0 IF OK, -1 IF ANY CHARACTER IS NOT A NUMBER
C
C  LOCAL VARIABLES
      integer ifc,iec,idc,ncint,isign,iexp,i,idum
C     IFC - FIRST CHARACTER WHICH IS NOT + OR -
C     IEC - LAST CHARACTER TO BE CONVERTED
C     IDC - CHARACTER NUMBER OF DECIMAL POINT
C     NCINT - NUMBER OF CHARACTERS IN INTEGER PART
C     ISIGN - +1 OR -1
      real*8 VAL
C       VALUE BUILT UP DURING SCAN OF CHARACTERS
C     IEXP - EXPONENT FOR SCALING
      integer jchar,ias2b,iscnc ! functions
C
C
C     SET UP THE CHARACTER COUNTERS NEEDED.  FIND THE DECIMAL POINT.
C     DETERMINE THE SIGN OF THE NUMBER.
C
      IERR = 0
      IFC = IC1
      IEC = IFC + NCH - 1
      IF (JCHAR(IAS,IC1).EQ.o'55'.OR.JCHAR(IAS,IC1).EQ.o'53') 
     .IFC = IFC + 1
      IDC = ISCNC(IAS,IFC,IEC,o'56')
      IF (IDC.EQ.0) IDC = IEC + 1
      NCINT = IDC - IFC
      ISIGN = +1
      IF (JCHAR(IAS,IC1).EQ.o'55') ISIGN = -1
C
C     CONVERT THE CHARACTERS IN THE INTEGER PART
C
      VAL = 0.D0
      IF (NCINT.EQ.0) GOTO 200
      DO 100 I=IFC,IDC-1
        IF (JCHAR(IAS,I).LT.o'60'.OR.JCHAR(IAS,I).GT.o'71') GOTO 990
        IEXP = IDC - I - 1
      IDUM = IAS2B(IAS,I,1)
        VAL = VAL + IAS2B(IAS,I,1)*10.D0**IEXP
100     CONTINUE
C
C     CONVERT THE CHARACTERS FOLLOWING THE DECIMAL POINT
C
200   IF (IDC.GE.IEC) GOTO 980
      DO 201 I = IDC+1, IEC
        IF (JCHAR(IAS,I).EQ.o'104'.OR.JCHAR(IAS,I).EQ.o'105') GOTO 300
        IF (JCHAR(IAS,I).EQ.o'144'.OR.JCHAR(IAS,I).EQ.o'145') GOTO 300
        IF (JCHAR(IAS,I).LT.o'60'.OR.JCHAR(IAS,I).GT.o'71') GOTO 990
        VAL = VAL + IAS2B(IAS,I,1)*10.D0**(IDC-I)
      IDUM=IAS2B(IAS,I,1)
      IEXP = IDC-I
201     CONTINUE
      GOTO 980
C
C     TAKE CARE OF THE EXPONENT FOUND AFTER THE "D" OR "E"
C
300   IEXP = IAS2B(IAS,I+1,IEC-I)
      VAL = VAL*10.D0**IEXP
C
C     FINISH UP NOW
C
980   RAS2B = VAL*ISIGN
      RETURN
C
C     HANDLE ERRORS HERE
C
990   IERR = -1
      RAS2B = 0.0
      RETURN
      END
