      SUBROUTINE CKOBS(cSOR,cSTN,NSTNSK,cCOD,ISOR,ISTNSK,ICOD)
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
C
C INPUT:
      character*2 cstn(*)
      character*2 ccod
      character*(Max_Sorlen) csor
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
! functions
      integer iwhere_in_string_list

C LOCAL:
      integer i

C  MODIFICATIONS:
C  880411 NRV DE-CMPLTD
C  930407 nrv implicit none
C  940609 nrv Satellite names have been moved to immediately
C             follow the celestial sources.
C 961101 nrv Codes undefined for this station are invalid too.
C 961107 nrv Don't check for undefined if this station isn't in this scan.
C 970114 nrv Change 4 to max_sorlen/2
C 200310Jun JMG Got rid of holleriths.
      isor=iwhere_in_string_list(csorna,nsourc,csor)
      IF (ISOR.EQ.0) THEN
        WRITE(LUSCN,9210) cSOR
9210    FORMAT('CKOBS01 -  SOURCE ',a,' NOT IN YOUR LIST.  QUITTING.')
        RETURN
      ENDIF

      istnsk=iwhere_in_string_list(cstn,nstnsk,cstcod(istn))
C
      icod=iwhere_in_string_list(ccode,ncodes,ccod)

      IF (ICOD.EQ.0) THEN
        WRITE(LUSCN,9230) cCOD
9230    FORMAT(' CKOBS02 - FREQUENCY CODE ',A,
     .  ' NOT FOUND IN YOUR SCHEDULE. QUITTING')
        RETURN
      ENDIF


      if (istnsk.ne.0.and.nchan(istn,icod).eq.0) then
        icod=0
        WRITE(LUSCN,9240) cCOD
9240    FORMAT(' CKOBS03 - FREQUENCY CODE ',A,
     .  ' not defined for your station. QUITTING')
        RETURN
      ENDIF
C
      RETURN
      END
