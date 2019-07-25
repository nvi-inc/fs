	SUBROUTINE CLIST(kskd)
C
C This routine reads a SNAP schedule file and makes a
C listing with all of the commands for one observation
C on one line.
C
C WEH 820921 FIX NCH TO PAD OUT WORD AFTER $120 AND $125
C            CATCH WRITING PAST END OF LINE $130 -> $140
C            ADD BREAK CHECK
C MWH 840813 Added printer LU lock, added exper name to header
C NRV 880411 DE-COMPC'D
C NRV 880422 Added page numbers
C NRV 880708 Added printer width option
C NRV 890419 Fixed buffer size and checks so that maximum printer
C            width is not exceeded (per CEK)
C PMR 900108 rewrote to use character strings
C nrv 900413 changed printer call to remove printer name
C            and add strings from control file
C            Added BREAK
C NRV 901206 Changed maxwidth and maxlines
C            Added call to SETPRINT
C NRV 910703 Added call to PRTMP at end.
C nrv 930407 implicit none

      INCLUDE 'skparm.ftni'
      INCLUDE 'drcom.ftni'
	INCLUDE 'statn.ftni'
C
C Input:
	logical kskd
C
C LOCAL:
      CHARACTER*256 BUF,LBUF
      INTEGER IC, TRIMLEN, IL, NCHAR, MAXLIN
      integer maxwid,ierr,nrec,iyear,i,npage,numlin,l
      character*8 cexper,cstn
      LOGICAL*4 EX
C     integer*4 ifbrk
C
C  First set up for proper width/length.

      IF (IWIDTH.EQ.80) THEN
	  MAXLIN = 47
	  maxwid = 70
      ELSE
C  MAXLIN = 64
C  maxwid = 110
          maxlin = 53
          maxwid = 140
      ENDIF
C
C   Check for existence of SNAP file.

      IC = TRIMLEN(SNPNAME)
      INQUIRE(FILE=SNPNAME,EXIST=EX)
      IF (.NOT.EX) THEN
        WRITE(LUSCN,9099) SNPNAME(1:IC)
9099    FORMAT(' CLIST01 - SNAP FILE ',A,' DOES NOT EXIST')
        RETURN
      ENDIF

	OPEN(UNIT=LU_INFILE,FILE=SNPNAME,STATUS='OLD',IOSTAT=IERR)
	IF (IERR.EQ.0) THEN
	  REWIND(LU_INFILE)
	  CALL INITF(LU_INFILE,IERR)
	ELSE
        WRITE(LUSCN,9060) IERR, SNPNAME(1:IC)
9060    FORMAT(' CLIST02 - ERROR ',I4,' OPENING SNAP FILE ',A)
        RETURN
      ENDIF

C  Read the first line to get the station name for the header
C  in case this is a SNAP file reading only.
	read(lu_infile,'(a)',err=990,end=990,iostat=IERR) buf
	nrec=1
	read(buf,9001) cexper,iyear,cstn
9001  format(2x,a8,2x,i4,1x,a8,2x,a1)
	if (.not.kskd) call char2hol(cstn,lstnna(1,1),1,8)
	WRITE(LUSCN,9100) (LSTNNA(I,ISTN),I=1,4),SNPNAME(1:ic)
9100  FORMAT(' SNAP COMMAND FILE LISTING FOR ',4A2,' FROM FILE ',A)
C
C
C  Setup printer for either landscape or portrait depending on iwidth
C
	call setprint(ierr,iwidth,0)
      IF (IERR.ne.0) THEN
        WRITE(LUSCN,9061) IERR
9061    FORMAT(' CLIST03 - ERROR ',I5,' accessing printer')
        RETURN
      ENDIF
C
      NCHAR = 1
      NPAGE = 0

C   Loop through SNAP FILE

110   IF (NPAGE.GT.0) call luff(luprt)
      NPAGE = NPAGE + 1
      NUMLIN = 0
C
	if (kskd) then
	  ic=trimlen(snpname)
	  write(luprt,9302) snpname(1:ic),(lstnna(i,istn),i=1,4),npage
9302    FORMAT(//'  SNAP Commands in file ',A,' for station ',
     .       4A2,10x,'Page ',I3//)
	else
	  write(luprt,9303) snpname(1:ic),cstn,npage
9303    format(//'  SNAP Commands in file ',A,' for station ',
     .       A8,10x,'Page ',i3//)
	endif

	if (nrec.eq.1) then !write out first line
	  l = trimlen(buf)
	  WRITE(LUPRT,9904) nrec,BUF(1:l)
	  NUMLIN = NUMLIN + 1
	endif

120   IF (NUMLIN.GE.MAXLIN) GOTO 110
      CALL clear_array(BUF)
      READ(LU_INFILE,'(A)',END=108,IOSTAT=IERR) BUF
      IL = TRIMLEN(BUF)
      IF (IERR.NE.0) GOTO 990
      NREC = NREC + 1
      IF (IL.GE.0) GOTO 125
C
C END OF FILE DETECTED

108   IL = -1
      NCHAR=MIN0(NCHAR,128)
      IF (NCHAR.GT.1) WRITE(LUPRT,9902) LBUF(1:NCHAR)
      GOTO 999
C
C WE HAVE A COMMAND IN THE BUFFER

125   IF ((BUF(1:6).NE.'SOURCE').AND.(BUF(1:1).NE.CHAR(34)))
     .    GOTO 130
      IF (NREC.EQ.1.OR.NCHAR.LE.1) GOTO 126
C
C SOURCE COMMAND OR COMMENT IS IN THE BUFFER
C FIRST WRITE OUT THE PREVIOUS LINE WITH OLD COMMANDS

	NCHAR = MIN0(NCHAR,128)
Cif (ifbrk().lt.0) goto 999
	WRITE(LUPRT,9902) LBUF(1:NCHAR)
9902  FORMAT(1X,6X,1X,A)
      NUMLIN = NUMLIN + 1
C
C NOW WRITE OUT THE CURRENT LINE NUMBER AND THE NEW SOURCE COMMAND

126   WRITE(LUPRT,9904) NREC, BUF(1:IL)
9904  FORMAT(1X,I6,1X,A)
	numlin = numlin + 1
      NCHAR = 1
      GOTO 120
130   CONTINUE

C
C CHECK TO MAKE SURE THAT THE COMMAND WILL FIT ON THE PAGE,
C IF NOT, THEN WRITE OUT BUFFER, AND CONTINUE

	IF ((NCHAR+IL+1).LE.(maxwid)) GOTO 140
      NCHAR=MIN0(NCHAR,128)
      NUMLIN = NUMLIN + 1
      WRITE(LUPRT,9902) LBUF(1:NCHAR)
      NCHAR=1
C
C ADD THE COMMAND TO THE END OF THE LINE AND ADD ONE BLANK

140   LBUF(NCHAR:NCHAR+IL+1) = BUF(1:IL) // ' '
      NCHAR = NCHAR+IL+1
      GOTO 120

990   if (ierr.ne.0) then
        WRITE(LUSCN,9990) IERR ,NREC
9990    FORMAT(' CLIST04 - ERROR ',I3,' READING RECORD ',I5)
        return
      endif

999   call luff(luprt)
      if (cprttyp.eq.'FILE') CLOSE(LUPRT)
      call prtmp
C
      RETURN
      END
