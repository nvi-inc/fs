C@ISCNS
C
      integer FUNCTION ISCNS(INPUT,ICST,ICEN,ICOMP,ICOMST,NCH)
C
C        ISCNS scans a string for the occurence of another string
C
C     INPUT VARIABLES:
C        ICST   - starting character in INPUT
C        ICEN   - last character in INPUT
C        ICOMST - starting character in ICOMP
C        NCH    - number of characters to compare
      integer*2 INPUT(*),ICOMP(*)
      integer icst,icen,nch
C   - input string array, compare string array
C
C     OUTPUT VARIABLES:
C        ISCNS - returns character in INPUT at which compare
C    string ICOMP begins
C
C  LOCAL VARIABLES
        integer ich,isc
C        ICH    - general character counter
C        ISC    - character found in scan
C
C  PROGRAMMER: NRV
C  930225 nrv implicit none
C
C
C     SCAN FOR THE OCCURENCE OF THE FIRST CHARACTER IN ICOMP
C
      ICH = ICST
100   IF (ICEN-ICH+1.GE.NCH) GOTO 101
      ISC = 0
      GOTO 990
101   ISC = ISCNC(INPUT,ICH,ICEN,JCHAR(ICOMP,ICOMST))
C
C     IF THIS CHARACTER NOT FOUND, RETURN ZERO FOR NO MATCH
C
      IF (ISC.EQ.0) GOTO 990
C
C     NOW COMPARE THE INPUT STRING WITH THE COMPARE STRING
C
      ICH = ICHCM(INPUT,ISC,ICOMP,ICOMST,NCH)
C
C     IF THE STRINGS MATCH WE ARE DONE, SO RETURN THE STARTING CHARACTER
C
      IF (ICH.EQ.0) GOTO 990
C
C     UPDATE THE FIRST CHARACTER TO USE IN THE SCAN AND LOOP BACK
C
      ICH = ISC + 1
      GOTO 100
C
990   ISCNS = ISC
      RETURN
      END
