       INTEGER FUNCTION ICHMV (LOUT,IFC,LINPUT,ICL,NCHAR)
       IMPLICIT NONE
       INTEGER LOUT(1),IFC,LINPUT(1),ICL,NCHAR 
C
C ICHMV: Hollerith character string mover
C
C Input:
C        LOUT: destination array
C        IFC: first character to fill in LOUT
C        LINPUT: source array
C        ICL: first character to move from LINPUT
C        NCHAR: number of characters to move
C
C Output:
C         ICHMV: IFC+NCHAR (next available character left-to-right)
C         LOUT: characters IFC...IFC+NCHAR-1 contain
C               characters ICL...ICL+NCHAR-1 from LINPUT
C               IF NCHAR.eq.0 then no-op.
C
C Warning:
C         Negative and zero values of IFC or ICL are not support
C         NCHAR must be non-negative
C         IFC+NCHAR.LT.32767
C         ICL+NCHAR.LE.32767
C
      INTEGER I,JCHAR,IEND
      character*72 string
C
      IF(ICL.LE.0.OR.IFC.LE.0.OR.NCHAR.LT.0) THEN
	  WRITE(string,*) ' ICHMV: Illegal arguments',IFC,ICL,NCHAR
          call put_stderr(string//char(0))
          call put_stderr('\n'//char(0))
        STOP
      ENDIF
C
      IF(NCHAR.EQ.0) then
        ICHMV=IFC
        RETURN
      ENDIF
C
      IEND=32767-NCHAR+1
C
      IF(IFC.GE.IEND.OR.ICL.GT.IEND) THEN
	  WRITE(string,*) ' ICHMV: Illegal combination',IFC,ICL,NCHAR
          call put_stderr(string//char(0))
          call put_stderr('\n'//char(0))
        STOP
      ENDIF
C
      DO I=0,NCHAR-1
        CALL PCHAR(LOUT,IFC+I,JCHAR(LINPUT,ICL+I))
      ENDDO
C
      ICHMV=IFC+NCHAR
C
      RETURN
      END
