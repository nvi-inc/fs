C
      LOGICAL FUNCTION KEARL(ITIM1,ITIM2)!COMPARE TWO TIMES
C
C  KEARL compares two times and returns .TRUE. if the first is earlier
C   than the second. Times are in the form yydddhhmmss (as found in
C   input schedule file).
C
C  HISTORY
C  900328  gag  copied from drudg to use with ptobs
C
      implicit none
      integer*2 ITIM1(6),ITIM2(6)
      integer jchar,i,i1,i2
      KEARL = .TRUE.
      DO 100 I=1,11
        I1 = JCHAR(ITIM1,I)
        I2 = JCHAR(ITIM2,I)
        IF(I1.GT.I2)GOTO 200
        IF(I1.LT.I2)GOTO 300
100   CONTINUE
200   KEARL = .FALSE.
300   CONTINUE
      RETURN
      END
