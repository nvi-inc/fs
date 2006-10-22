	SUBROUTINE GTSNP(ICH,NCHAR,IC1,IC2,kcomment)
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C
C  Input:
      integer ich,nchar,ic1,ic2
      logical kcomment
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
C 020606 nrv Add kcomment to indicate a comment was found

100   CALL GTFLD(IBUF,ICH,NCHAR,IC1,IC2)
      kcomment=.false.
      IF (IC1.EQ.0) THEN !end of this record
	  CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	  IF (IERR.LT.0.OR.ILEN.LT.0) THEN
	    RETURN
	  ENDIF
          if(cbuf(1:1) .ne. "-") then
C Back up to just before the record
	    RETURN
	  ELSE ! continuation record
	    ICH = 2
	    NCHAR = ILEN
	    GOTO 100
	  ENDIF
	ENDIF
C
	IF (cbuf(ic1:ic1) .eq. '"') then
          kcomment = .true.
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
