      LOGICAL FUNCTION KNAEQ(L1,L2,ILEN)
C
C     Returns TRUE if all words of names L1 and L2 are equal.  This is
C     a test of equality of string names.
C
      include '../skdrincl/skparm.ftni'
C
      integer*2 L1(*),L2(*)
      integer ilen,i
C
      I=1
      DO WHILE ((I.LE.ILEN).AND.(L1(I).EQ.L2(I)))
        I=I+1
      END DO
C                   Increment counter while words are equal
      IF  (I.EQ.ILEN+1)  THEN
        KNAEQ=.TRUE.
      ELSE
        KNAEQ=.FALSE.
      ENDIF
      RETURN
      END
