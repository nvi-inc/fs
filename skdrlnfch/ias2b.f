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
      FUNCTION IAS2B(INCHR,IFCHR,N)!C#880608:11:32    #
C
! AEM 20041229 add implicit and enumerate variables and functions
      implicit none
      integer ifchr,n,isign,ix,ic,i,jchar
      
      INTEGER IAS2B
      INTEGER Z30,Z39,Z2D,Z2B,Z20
C       INTEGER Z8000
C
C 1.  NAME PROGRAM SPECIFICATION
C
C 1.1 IAS2B        THIS ROUTINE CONVERTS N CHARACTERS TO
C                  AND INTEGER AND RETURNS THE VALUE TO THE USER
C                  LEADING BLANKS ARE IGNORED AND A MINUS SIGN
C                  GIVES A NEGATIVE NUMBER
C
C 1.2. RESTRICTIONS - limits on use of routine
C 1.3. REFERENCES - document cited
C
C 2.  NAME INTERFACE
C
C 2.1. CALLING SEQUENCE: INT=IAS2B(INCHR,IFCH,N)
C
C     INPUT VARIABLES:
C 
C       IFCHR   - THE FIRST CHARACTER IN INCHR TO BE USED 
C       N       - THE NUMBER OF CHARACTERS TO BE USED 
C 
      integer*2 INCHR(2)
c      DIMENSION INCHR(2)
C ADDED 900709
	DATA Z30/Z'30'/, Z39/Z'39'/, Z2D/Z'2D'/, Z2B/Z'2B'/, Z20/Z'20'/
C       DATA Z8000/Z'8000'/
C
C       INCHR   - THE CHARACTER STREAM TO BE CONVERTED TO AN INTEGER
C 
C 
C     OUTPUT VARIABLES: 
C 
C       IAS2B   - THE INTEGER RESULTING FROM THE CONVERSION 
C                   IF ANY INVALID CHARACTERS ARE FOUND A -32768 IS RETURNED
C 
C 2.5. SUBROUTINE INTERFACE:
C 
C      THIS IS A UTILITY ROUTINE
C      CALLED SUBROUTINES: JCHAR
C 
C 3. LOCAL VARIABLES
C 
C       ISIGN   - THE SIGN HOLDER (=+1 UNLESS A - PRECEEDS NUMBER)
C       IX      - USED TO COMPUTE BINARY VALUE OF RESULT
C 
C 6. PROGRAMMER: LEE N. FOSTER
C    LAST MODIFIED:
C# LAST COMPC'ED  880608:11:32urrent date) #
C 
C    PROGRAM STRUCTURE
C 
C  6.1 INIALIZE STATE VARAIBLES
	ISIGN=1
	IX=0
C 
C  6.2 LOOP THROUGH A CHARACTER AT A TIME
	DO 500 I=1,N
C 
C      GET THE CHARACTER ISOLATED
	  IC=JCHAR(INCHR,IFCHR+I-1)
C 
C      IS IT AN INTEGER
	  IF(Z30 .LE. IC .AND. IC .LE. Z39) GO TO 300
C 
C      IF NOT A INTEGER HAS AN ONE BEEN FOUND
	  IF( IX .NE. 0) GO TO 910
C 
C      IS IT A SIGN AS IN -
	  IF(IC .EQ. Z2D) GO TO 200
C 
C      DID SOMEBODY GIVE US A +
	  IF(IC .EQ. Z2B) GO TO 500
C 
C      BLANKS ONLY OTHER THING PERMITTED
	  IF(IC .EQ. Z20) GO TO 500
C 
C      IF NONETHING HAS WORKED ABORT
	  GO TO 910
200     CONTINUE
C 
C      RECORD MINUS SIGN OCCURRENCE
	  ISIGN=-1
	  GO TO 500
300     CONTINUE
C 
C      INTEGERS ARE EASY TO HANDLE
	  IX=10*IX+IC-Z30
500   CONTINUE
C 
C 6.2 MERGE SIGN AND NUMBER INFORMATION TO RESULT
	IAS2B=ISIGN*IX
	GO TO 999
C
910   CONTINUE
C
C 6.3 SIGNAL ERROR RESULT (LARGEST NEGATIVE NUMBER)
c	IAS2B=Z8000
	IAS2B=-32768
999   CONTINUE
      RETURN
      END
