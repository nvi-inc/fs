      SUBROUTINE CKOBS(LSOR,LSTN,NSTNSK,LCOD,ISOR,ISTNSK,ICOD)
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
C
C INPUT:
      integer*2 lsor(4),lstn(max_stn),lcod
      integer nstnsk,isor,istnsk,icod
C  source name, list of stations
C  NSTNSK - number of stations this observation
C  LCOD  - frequency code for this observation
C
C OUTPUT:
C  ISOR - source index into COMMON arrays
C  ISTNSK - which station in the observation
C  ICOD - which code in the COMMON list
C
C LOCAL:
      integer i,j,l
      integer jchar,ichcm ! function

C  MODIFICATIONS:
C  880411 NRV DE-CMPLTD
C  930407 nrv implicit none
C  940609 nrv Satellite names have been moved to immediately
C             follow the celestial sources.
C 961101 nrv Codes undefined for this station are invalid too.
C 961107 nrv Don't check for undefined if this station isn't in this scan.
C
      ISOR = 0
      I = 1
10    IF (I.GT.NSOURC) GOTO 20
      J = I
C     IF( I.GT.NCELES) I=I+MAX_CEL-NCELES
      IF (ICHCM(LSOR,1,LSORNA(1,J),1,8).EQ.0) ISOR=J
      I = I + 1
      GOTO 10
20    CONTINUE
C
      IF (ISOR.EQ.0) THEN
        WRITE(LUSCN,9210) LSOR
9210    FORMAT('CKOBS01 -  SOURCE ',4A2,' NOT IN YOUR LIST.  QUITTING.')
        RETURN
      ENDIF
      ISTNSK = 0
      L = JCHAR(LSTCOD(ISTN),1)
      DO I=1,NSTNSK
        IF (JCHAR(LSTN(I),1).EQ.L) ISTNSK=I
      ENDDO
C
      ICOD = 0
      DO I=1,NCODES
        IF (LCOD.EQ.LCODE(I)) ICOD=I
      ENDDO
      IF (ICOD.EQ.0) THEN
        WRITE(LUSCN,9230) LCOD
9230    FORMAT(' CKOBS02 - FREQUENCY CODE ',A2,
     .  ' NOT FOUND IN YOUR SCHEDULE. QUITTING')
        RETURN
      ENDIF
      if (istnsk.ne.0.and.nchan(istn,icod).eq.0) then
        icod=0
        WRITE(LUSCN,9240) LCOD
9240    FORMAT(' CKOBS03 - FREQUENCY CODE ',A2,
     .  ' not defined for your station. QUITTING')
        RETURN
      ENDIF
C
      RETURN
      END
