	SUBROUTINE GTSNP(ICH,NCHAR,IC1,IC2)
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C
C  Input:
      integer ich,nchar,ic1,ic2
C
C  Local:
	integer*4 IREC,ierr,ilen
	integer Z2D,Z22
        integer jchar,iscnc ! functions

C Initialized:
	DATA      Z2D/Z'2D'/, Z22/Z'22'/
C
C History:
C nrv 930407 implicit none

100   CALL GTFLD(IBUF,ICH,NCHAR,IC1,IC2)
      IF (IC1.EQ.0) THEN !end of this record
	  CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	  IF (IERR.LT.0.OR.ILEN.LT.0) THEN
	    RETURN
	  ENDIF
	  IF (JCHAR(IBUF,1).NE.Z2D)   THEN ! whoops - not ours!
	    call locf(LU_INFILE,IREC)
	    call aposn(LU_INFILE,IERR,irec-1)
C Back up to just before the record
	    RETURN
	  ELSE ! continuation record
	    ICH = 2
	    NCHAR = ILEN
	    GOTO 100
	  ENDIF
	ENDIF
C
	IF (JCHAR(IBUF,IC1).EQ.Z22) THEN ! comment
	  IC2 = ISCNC(IBUF,IC1+1,NCHAR,Z22)
C Find the next quote
	  IF (IC2.EQ.0) THEN ! no closing quote
	    IC2 = NCHAR
	    ICH = NCHAR+1
	  ELSE
	    ICH=IC2+1
	  ENDIF
	ENDIF
C
      RETURN
      END
