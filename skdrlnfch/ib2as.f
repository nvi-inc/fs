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
      FUNCTION ib2as(IN,IOUT,IC,NC)
      IMPLICIT NONE
      INTEGER ib2as
C NRV 951015 Change AND to IAND
C
C 1.1.ib2as  THIS ROUTINE RETURNS AN ASCII CHARACTER STRING
C            FOR THE INTEGER IN IN STARTING AT THE IC CHARACTER
C            IN IOUT AND GOING FOR NC CHARACTERS
C
C 1.2. RESTRICTIONS - limits on use of routine
C       THIS ROUTINE WILL TRUNCATE IN THE SAME MANNER AS FORTRAN
C       IF THERE ARE TOO MANY CHARACTERS GENERATED IN THE PROCESS
C
C INPUT VARIABLES:
C   IN      - THE INTEGER TO BE CONVERTED
C   IC      - SIGN CONTROL AND THE LOCATION OF THE FIRST CHARACTER
C             TO USE IN IOUT
C
C             S0000000XXXXXXXX
C
C             S - IF 1 ALWAYS HAVE A LEADING SIGN
C                 ELSE SIGN ONLY IF A NEGATIVE NUMBER INPUT
C             XXXXXXXX - NUMBER OF CHARACTERS TO GENERATE IN IOUT
C
C   NC      - LEFT SHIFT CONTROL, ZERO PREFILL CONTROL, PREFILL
C             COUNT AND NUMBER OF CHARACTERS TO GENERATE
C
C             LZPPPPPPYYYYYYYY
C             L - IF 1 SHIFT RESULT TO LEFT IN IOUT
C             Z - IF 1 PREFILL WITH ZEROS UP TO COUNT PPPPPP
C
C             PPPPPP - PREFILL COUNT LIMIT
C             YYYYYYYY - THE NUMBER OF CHARACTERS TO GENERATE
C                        IN IOUT(MAXIMUM VALUE FOR ib2as)
C
C OUTPUT VARIABLES:
C
C  ib2as   - THE NUMBER OF CHARACTERS GENERATED BY THIS ROUTINE OR
C            -1 IF AN ERROR OCCURS
C
! AEM 20050111 int->int*2
      INTEGER*2 IOUT(2)
C
C  IOUT    - THE STRING INTO WHICH THE INTEGER IS TO BE PUT
C
C 3. LOCAL VARIABLES
C
C      I       - THE INTERNAL MODIFIED NUMBER TO BE CONVERTED
C      IDO     - THE NUMBER OF BYTES THAT MUST BE HANDLED THIS ROUND
C      IIC     - FIRST CHARACTER IN IOUT TO MODIFY
C      IIP     - PREFILL LOOPING INDEX
C      ILPE    - WHERE THE INTEGER GENERATION  LOOP SHOULD END
C      ILPS    - WHERE THE INTEGER GENERATION LOOP STARTS
C      INM     - NUMBER OF CHARACTERS GENERATED BY THIS ROUTINE
C      IPFC    - INTERNAL PRE FILL LIMIT
C      IWDR    - THE NUMBER OF THE WORD PAST FIRST REFERENCED IN IOUT
C      IWDS    - THE NUMBER OF WORDS MODIFIED IN IOUT BY THIS ROUTINE
C      IWR0    - THE WORD PRIOR TO THE FIRST WORD IN IOUT MODIFIED
C      IXR     - THE WORD REFERENCE FOR IX INSIDE DO LOOP
C                NOTE:  THE CHARACTER ARE DETERMINED FROM LOW
C                       ORDER FIRST TO HIGH ORDER ONE.  THIS IS
C                       USED IN THE REFERENCE PROCESS
C      J       - CHARACTER PROCESSING LOOP PARAMETER
C      J1      - CHARACTER SHIFTING AND FILLING INDEX
C      JM      - # OF CHARACTERS THAT NEED SHIFTING
C      JP1     - POSITION LAST SHIFTED CHARACTER OCCUPIES
C      JSHF    - THE DISTANCE THE CHARACTERS MUST BE SHIFTED
C      NIC     - THE NUMBER OF CHARACTERS IN IOUT TO BE FILLED
C
      INTEGER I,IC,ICHMV,IDT,IIC,IN,IPFC,ISIGN,J,JEND,
     .        JJ,NC,NIC,ix,itemp
c     integer idum,jchar
c
C
C 4. CONSTANTS USED
! AEM 20050111 int->int*2
      INTEGER*2 ISGN(3)
C
c added 900626
      INTEGER zff,Z8000,Z30,Z4000,Z3F00
c     integer z3f
      DATA ISGN/Z'20',Z'2D',Z'2B'/
c added 900626
      DATA ZFF/Z'FF'/,Z8000/Z'8000'/,Z30/Z'30'/,
     .     Z4000/Z'4000'/,Z3F00/Z'3F00'/
c     data z3f/Z'3f'/
C
C   ISGN    - THIS IS THE SIGN CHARACTER FOR THE OUTPUT
C             z'20' - A BLANK FOR THE NONEGATIVE CASE
C             z'2d' - A MINUS SIGN FOR THE NEGATIVE CASE
C             z'2b' - A PLUS SIGN FOR FORCED LEADING SIGN
C
C 5. INITIALIZED VARIABLES
C 6. PROGRAMMER: LEE N. FOSTER
C    LAST MODIFIED:
C    PROGRAM STRUCTURE
C
C 6.1 INITIALIZE VARIABLES AND DECIDE WORK STRATEGY
C
      NIC=iAND(NC,zff)
c      ipfc=iand(jchar(nc,1),z3f)
c      IPFC=IAND(JCHAR(NC,2),z3f)
      ipfc= iand(Z3F00,NC)/256
      IIC=iAND(IC,zff)
      JEND=IIC+NIC-1
      ISIGN=1
      ix=z8000
      IF(iAND(IC,ix) .NE. 0) ISIGN=3
      I=IABS(IN)
      IF(IN .LT. 0) ISIGN=2
C
C FILL OUTPUT WITH BLANKS FIRST
      CALL IFILL_ch(IOUT,IIC,NIC,' ')
C
C 6.2 SETUP LOOPING PARAMETERS AND CONVERT NUMBER
      DO 200 JJ=JEND,IIC,-1
        J=JJ
C GET TENS QUOTIENT
        IDT=I/10
C GET THE DIGIT AND CONVERT IT TO ASCII
        call pchar(iout,j,i-(10*idt)+z30)
c        idum=ichmv(iout,j,(i-(10*idt)+z30),1,1)
c        IDUM=ICHMV(IOUT,J,(I-(10*IDT)+z30),2,1)
C UPDATE I FOR THE NEXT ROUND
        I=IDT
C HAS THE NUMBER ENDED (I. E. HAS ZERO BEEN REACHED)
        IF(IDT .NE. 0) GO TO 200
C STEP J BACK FOR NEXT JOB
        J=J-1
C
C IS ZERO PREFILL REQUESTED
        IF(iAND(NC,Z4000) .EQ. 0) GO TO 130
C FIND PREFILL COUNT LIMIT
        IPFC=min0(IPFC,J-IIC+1)
C LEAVE ROOM FOR SIGN IF NEEDED
        IF(ISIGN .NE. 1) IPFC=IPFC-1
C CHECK TO SEE IF ANYTHING LEFT TO FILL
        IF(IPFC .LE. 0) GO TO 130
C MOVE IN ZERO
        CALL IFILL_ch(IOUT,J-IPFC+1,IPFC,'0')
C RESET J FOR LATER USE
        J=J-IPFC
130     CONTINUE
C
C IS A SIGN CHARACTER NEEDED
        IF(ISIGN .EQ. 1) GO TO 140
C IS THE RANGE EXCEEDED
        IF(J .LT. IIC) GO TO 910
C INSERT SIGN THERE IS ROOM
        itemp=isgn(isign)       !need this because pchar is expecting integer
        call pchar(iout,j,itemp)
c        idum=ichmv(iout,j,isgn(isign),1,1)
c        IDUM=ICHMV(IOUT,J,ISGN(ISIGN),2,1)
C STEP BEFORE THE SIGN INSERT
        J=J-1
140     CONTINUE
C
C STEP J TO LAST CHARACTER PUT IN STRING
        J=J+1
C CHECK FOR LEFT SHIFT DESIRED AND NEEDED
        ix=Z8000
        IF(iAND(NC,ix) .EQ. 0 .OR. J .LE. IIC) GO TO 300
C CALCULATE NUMBER OF CHARACTERS GENERATED
        ib2as=JEND-J+1
C SHIFT DATA OVER AND FILL THE REST WITH BLANKS
        CALL IFILL_ch(IOUT,ICHMV(IOUT,IIC,IOUT,J,ib2as),NIC-ib2as,' ')
        GO TO 999
200   CONTINUE
C
C IF EXIT HERE NUMBER TOO BIG FOR FIELD HENCE ERROR
      GO TO 910
300   CONTINUE
C ALL CHARACTERS USED SO TELL USER
      ib2as=NIC
C NOW EXIT
      GO TO 999
910   CONTINUE

C OVERFLOW HAS OCCURRED SENT DOLLAR SIGNS BACK($)
C NUMBER TOO LONG FOR FIELD SEND DOLLAR SIGNS($)
      CALL IFILL_ch(IOUT,IIC,NIC,'$')
C NOTE ERROR IN CALL
      ib2as=-1
999   CONTINUE
C
      RETURN
      END
