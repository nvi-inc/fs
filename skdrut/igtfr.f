      integer FUNCTION IGTFR(LKEYWD,IKEY)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
C     CHECK THROUGH LIST OF CODES FOR A MATCH WITH LKEYWD
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
      integer*2 lkeywd(*)
      integer ikey,i
      IKEY=0
      IGTFR = 0
      IF (NCODES.LE.0) RETURN
      DO 100 I=1,NCODES
        IF (LCODE(I).EQ.LKEYWD(1)) GOTO 110
100   CONTINUE
      RETURN
110   IKEY=I
      IGTFR = I
      RETURN
      END
