      SUBROUTINE READS(IUNIT,KERR,IBUF,IBLEN,IL,IMODE)
C
C  READS reads the schedule file lines.
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer iunit,iblen,imode
C     IBLEN - length of IBUF, IN WORDS
C     IMODE - mode for reading
C             1 = get the next record with $ in column 1
C             2 = get the next non-comment, stop when a record
C                 with $ in col. 1 is encountered.
C                 A comment card has * in column 1
C
C  OUTPUT:
      integer il,kerr
      integer*2 ibuf(*)
C      ibuf - buffer for reading
C     IL - length of record read IN CHARACTERS, -1 means EOF
C     KERR - error return from FMP
C 
C  LOCAL:
      integer jchar ! function
C HISTORY:
C  LAST MODIFIED: CREATED 800809
C                 CLEAR BUFFER BEFORE EACH READ!  810705
C    880315 NRV DE-COMPC'D
C    880524 PMR changed READF to READL
C               added char2hol calls
C    900205 NRV Added check for zero-length records, if found read 
C               another record.
C    930225 nrv implicit none
C    951002 nrv Add mode 3 = read next line of any type
C    2003Oct14 JMGipson. Add code to handle ^M at the end of a line--
C              Most likely due to transfer from Dos to UX.

C
C     0. INITIALIZE
C
      KERR = 0
      IL = 0
      CALL IFILL(IBUF,1,IBLEN*2,oblank)  !fill with blanks to initiliaze.
C
C
C     1. This section handles mode 1: get next "$" line.
C
      IF  (IMODE.EQ.1) THEN  !
        call char2hol('  ',IBUF,1,2)
        DO WHILE (JCHAR(IBUF,1).NE.ODOLLAR.AND.IL.NE.-1.AND.KERR.EQ.0
     .     .or.il.eq.0)
          CALL IFILL(IBUF,1,IBLEN*2,oblank)
          CALL READF_ASC(IUNIT,KERR,IBUF,IBLEN,IL)
          call inc(IUNIT,KERR)
          if (il.eq.0) call char2hol('  ',IBUF,1,2)
        END DO  !
      END IF  !
C
C
C     2. This section handles mode 2: get next line until "$".
C
      IF  (IMODE.EQ.2) THEN 
        call char2hol ('**',IBUF,1,2)
        DO WHILE (JCHAR(IBUF,1).EQ.OSTAR.AND.IL.NE.-1.AND.KERR.EQ.0.AND.
     .         JCHAR(IBUF,1).NE.ODOLLAR.or.il.eq.0)
          CALL IFILL(IBUF,1,IBLEN*2,oblank)
          CALL READF_ASC(IUNIT,KERR,IBUF,IBLEN,IL)
          call inc(IUNIT,KERR)
          if (il.eq.0) call char2hol('**',ibuf,1,2)
        END DO  !
      END IF  !
C
C     3. This section handles mode 3: get next line 

      if (imode.eq.3) then
          CALL IFILL(IBUF,1,IBLEN*2,oblank)
          CALL READF_ASC(IUNIT,KERR,IBUF,IBLEN,IL)
          call inc(IUNIT,KERR)
          if (il.eq.0) call char2hol('  ',ibuf,1,2)
      END IF  !

C     Convert to number of characters
      IF (IL.NE.-1) IL = IL*2
      RETURN
      END
