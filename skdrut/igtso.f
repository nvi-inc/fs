      integer FUNCTION IGTSO(LKEYWD,IKEY)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'
C     CHECK THROUGH LIST OF SOURCES FOR A MATCH WITH LKEYWD
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
C     ALSO MAY HAVE A SOURCE INDEX NUMBER ALLOWED.
C 970114 nrv Change 4 to max_sorlen/2
      integer*2 LKEYWD(*)
      integer ikey,i,ias2b,iflch
      LOGICAL KNAEQ
      IKEY=0
      IGTSO = 0
      IF (NSOURC.LE.0) RETURN
      DO 100 I=1,NSOURC
        IF (KNAEQ(LKEYWD,LSORNA(1,I),max_sorlen/2)) GOTO 110
100   CONTINUE
      I = IAS2B(LKEYWD,1,IFLCH(LKEYWD,8))
      IF (I.GT.0.AND.I.LE.NSOURC) GOTO 110
      RETURN
110   IKEY=I
      IGTSO = I
      RETURN
      END
