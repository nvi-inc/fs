      integer FUNCTION IGTST(LKEYWD,IKEY)
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
C
C     SEARCH THROUGH THE STATION CODES FOR A MATCH WITH
C     THE FIRST CHARACTER OF THE INPUT VARIABLE.
C!     RETURN THE INDEX IN THE FUNCTION AND IN IKEY.
C     NO MATCH RETURNS 0.

      integer*2 lkeywd(*)
      integer ikey,i,jchar
      IKEY=0
      IGTST=0
      IF (NSTATN.LE.0) RETURN
      DO 100 I=1,NSTATN
        IF (JCHAR(LKEYWD,1).EQ.JCHAR(LSTCOD(I),1)) GOTO 110
100   CONTINUE
      RETURN
110   IKEY=I
      IGTST=I
      RETURN
      END
