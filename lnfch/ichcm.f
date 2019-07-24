       INTEGER FUNCTION ICHCM (AR1,IFC1,AR2,IFC2,NCHAR)
       IMPLICIT NONE
       INTEGER AR1(1),IFC1,AR2(1),IFC2,NCHAR
C
C ICHCM: compare to hollerith strings
C
C Input:
C        AR1:   array holding first string
C        IFC1:  first character to use in AR1
C        AR2:   array holding second string
C        IFC2:  first character to use in AR2
C        NCHAR: number of characters to compare
C
C Output:
C        ICHCM: zero if the two string match
C               +/- index of first character to not match
C                   1 <= ABS(ICHCM) <= NCHAR in this case
C               + value if character in AR1 < character in AR2
C               - value if character in AR1 > character in AR2
C
C Warning:
C         Negative and zero values of IFC1 or IFC2 are not support
C         NCHAR must be non-negative
C         IFC1+NCHAR.LE.32767
C         IFC2+NCHAR.LE.32767
C
      INTEGER I,JCHAR,IEND,I1,I2
C
      IF(IFC1.LE.0.OR.IFC2.LE.0.OR.NCHAR.LT.0) THEN
	  WRITE(6,*) ' ICHCM: Illegal arguments',IFC1,IFC2,NCHAR
        STOP
      ENDIF
C
      IF(NCHAR.EQ.0) then
        ICHCM=0
        RETURN
      ENDIF
C
      IEND=32767-NCHAR+1
C
      IF(IFC1.GT.IEND.OR.IFC2.GT.IEND) THEN
	  WRITE(6,*) ' ICHCM: Illegal combination',IFC1,IFC2,NCHAR
        STOP
      ENDIF
C
      ICHCM=0
      DO I=0,NCHAR-1
        I1=JCHAR(AR1,IFC1+I)
        I2=JCHAR(AR2,IFC2+I)
        IF(I1.NE.I2) THEN
          ICHCM=I+1
          IF(I2.LT.I1) ICHCM=-ICHCM
          RETURN
        ENDIF
      ENDDO
C
      RETURN
      END
