      SUBROUTINE CHAR2HOL(CH,IARR,IFC,ILC)
C CHAR2HOL: move a character variable into a hollerith string
C           blank fill to the right
      IMPLICIT NONE
      CHARACTER*(*) CH
      INTEGER IARR(1),IFC,ILC
C
C Input:
C   CH:   character string
C   IFC:  first position in IARR to move
C   ILC:  last position in IARR to move
C   IARR: destination Hollerith string
C
C Output:
C   IARR: characters IFC...ILC contain CH
C         blank filled to the right if necessary
C
      INTEGER IWORD,LN,IEND,I
C
      LN=ILC-IFC+1
      IEND=MIN(LN,LEN(CH))
      DO I=1,IEND
	  IWORD=ichar(CH(I:I))
        CALL PCHAR(IARR,IFC+I-1,IWORD)
      ENDDO
      IF(IEND.LT.LN) THEN
          IWORD=ichar(' ')
        DO I=IEND+1,LN
          CALL PCHAR(IARR,IFC+I-1,IWORD)
        ENDDO
      ENDIF
C
      RETURN
      END
