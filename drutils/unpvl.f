	SUBROUTINE unpvl(IBUF,ILEN,IERR,lst,lfr)
C
C     UNPVL unpacks the L lines of the $VLBA section of
C     a schedule file.
C
      include 'skparm.ftni'

C  History:
C  WHEN    WHO  WHAT
C  900716  GAG  Created, modeled after UNPFR 
C  910524  NRV  Removed LO group code
C  930225  nrv  implicit none
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C      - buffer having the record
C     ILEN - length of the record in IBUF, in words.
C
C  OUTPUT
      integer ierr
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
	integer*2 LFR(4)      ! name of frequency code, 8 char
	integer*2 lst(4)      ! name of station

C
C  SUBROUTINES CALLED: LNFCH UTILITIES
C
C  LOCAL:
      integer ich,nch,ic1,ic2,idumy
      integer ichmv ! functions
C
C
      IERR = 0
      ICH=1 
C 
C     Station Name - 8 characters
C 
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) 
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN 
        IERR = -101
        RETURN
      END IF
	CALL IFILL(LST,1,8,32)
	IDUMY = ICHMV(LST,1,IBUF,IC1,NCH)
C
C     Frequency code name, 8 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
	IF  (NCH.GT.8) THEN
	  IERR = -102
        RETURN
      END IF 
	call char2hol ('        ',Lfr,1,8)
	IDUMY = ICHMV(Lfr,1,IBUF,IC1,NCH)
C
C
      RETURN
      END
