      integer FUNCTION IGTBA(LKEYWD,IKEY)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
C     Check through all bands for a match with the first character
C     of LKEYWD.
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
      integer*2 lkeywd(*)
      integer ikey,i,jchar
      IKEY=0
      IGTBA = 0
      IF (NBAND.LE.0) RETURN
      DO 100 I=1,NBAND
        IF (jchar(LBAND(I),1).eq.jchar(LKEYWD,1)) GOTO 110
100   CONTINUE
      RETURN
110   IKEY=I
      IGTBA = I
      RETURN
      END
