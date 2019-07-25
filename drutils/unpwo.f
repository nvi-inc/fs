      SUBROUTINE unpwo(IBUF,ILEN,IERR,
     .  OINC,OECC,OPER,ONOD,OANM,OAXS,OMOT,IEPY,OEDY,ICH)
C
C     UNPWO unpacks the satellite specific information in a source record.
C           This routine is a utility to unpso.
C
       INCLUDE 'skparm.ftni'
C
C  HISTORY:
C     WEH  820519  CREATED
C     NRV  880315  DE-COMPC'D
C     nrv  930225  implicit none
C     nrv  940110  re-instated in sked, add error return in das2b call
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,ich
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C     ICH  - the number of characters in IBUF that were processed by
C            UNPVS
C
C  OUTPUT:
      integer ierr
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C   Satellite orbit info:
      real*8 OINC ! orbit inclination
      real*8 OECC ! orbit eccentricity
      real*8 OPER ! orbit arguement of the perigee
      real*8 ONOD ! orbit right ascending node
      real*8 OANM ! orbit anomaly
      real*8 OAXS ! orbit semi-major axis
      real*8 OMOT ! orbit motion
      integer iepy ! IEPY - orbit epoch year
      real*8 OEDY ! orbit epoch day
C
C  SUBROUTINES CALLED: LNFCH UTILITIES
C
C  LOCAL:
      real*8 DAS2B,dvar
      integer ic1,ic2,kerr
      integer ias2b ! function
C
C  INITIALIZED:
C
C
C   Orbit Inclination.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      OINC =DAS2B(IBUF,IC1,IC2-IC1+1,kerr)
      IF  (OINC  .LT.-360.0 .OR.  OINC  .GT.360.0D0) THEN  !
        IERR=-103
        RETURN
      END IF  !
C
C       Orbit eccentricity.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      dvar =DAS2B(IBUF,IC1,IC2-IC1+1,kerr)
      oecc=dvar
      IF  (OECC  .LT. 0.0D0 .OR.  OECC  .GT. 1.0D0  ) THEN  !
        IERR=-104
        RETURN
      END IF  !
C
C       Orbit arguement of perigee.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      OPER=DAS2B(IBUF,IC1,IC2-IC1+1,kerr)
      IF  (OPER .LT.-360.D0 .OR.  OPER .GT.360.0D0) THEN  !
        IERR=-105
        RETURN
      END IF  !
C
C       Orbit right ascending node.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      ONOD=DAS2B(IBUF,IC1,IC2-IC1+1,kerr)
      IF  (ONOD .LT.-360.D0 .OR.  ONOD .GT.360.0D0) THEN  !
        IERR=-106
        RETURN
      END IF  !
C
C       Orbit anomaly.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      OANM=DAS2B(IBUF,IC1,IC2-IC1+1,kerr)
      IF  (OANM .LT.-360.D0.OR.  OANM .GT.360.D0 ) THEN  !
        IERR=-107
        RETURN
      END IF  !
C
C       Orbit semi-major axis.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      OAXS=DAS2B(IBUF,IC1,IC2-IC1+1,kerr)
      IF  (OAXS .LT.0.0D0 ) THEN  !
        IERR=-108
        RETURN
      END IF  !
C
C       Orbit motion.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      OMOT=DAS2B(IBUF,IC1,IC2-IC1+1,kerr)
      IF  (OMOT .LT. 0.0D0 ) THEN  !
        IERR=-109
        RETURN
      END IF  !
C
C      Orbit epoch year.  If this program is still being used in
C       in the year 2000, make someone think about the accuracy of
C       the time calculations (sideral, modified Julian day, etc.).
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IEPY =IAS2B(IBUF,IC1,IC2-IC1+1)
      IF  (IEPY  .LT. 1959 .OR.  IEPY  .GT.1999 ) THEN  !
        IERR=-110
        RETURN
      END IF  !
C
C       Orbit epoch day.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      OEDY=DAS2B(IBUF,IC1,IC2-IC1+1,kerr)
      IF  (OEDY .LT.0.0D0  .OR.  OEDY .GT.366.0D0) THEN  !
        IERR=-111
        RETURN
      END IF  !
C
C        Done.
C
      RETURN
      END
