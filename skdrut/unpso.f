      SUBROUTINE unpso(IBUF,ILEN,IERR,lname1,lname2,
     .LRAHMS,IRAH,IRAM,RAS,RARAD,
     .LDSIGN,LDCDMS,IDECD,IDECM,DECS,DECRAD,EPOCH,
     .OINC,OECC,OPER,ONOD,OANM,OAXS,OMOT,IEPY,OEDY,
     .pcount)
C
C     UNPSO unpacks the record holding information on a source entry version
C     ****pcount UNIMPLEMENTED**** 
C     pcount=5 gets only source names
C            17 gets names, ra, dec
C            26 gets satellite info
C
      include '../skdrincl/skparm.ftni'
C
C  HISTORY:
C      NRV   891110  Modified UNSKS for use by new catalog routines
C   nrv 930225 implicit none
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr,irah,iram,idecd,idecm
      integer*2 ldsign
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
      integer*2 LNAME1(4), LNAME2(4) ! IAU and common names
C   Celestial Source Info:
      integer*2 LRAHMS(8)
C          - right ascension, in form hhmmss.ssssssss
C     IRAH,IRAM - right ascension hours&minutes, in binary
      real*8 RAS
C           - seconds field of right ascension
      real*8 RARAD
C           - right ascension, in radians
C     LDSIGN - sign of the declination, + or -
      integer*2 LDCDMS(7)
C           - declination, in form ddmmss.sssssss
C     IDECD,IDECM - declination degrees&minutes, in binary
      real*8 DECS
C           - declination seconds field
      real*8 DECRAD
C           - declination, in radians
C     EPOCH - epoch of RA and DEC
      real*4 epoch
C
C   Satellite orbit info:
C
      real*8 OINC
C           - orbit inclination
      real*8 OECC
C           - orbit eccentricity
      real*8 OPER
C           - orbit arguement of the perigee
      real*8 ONOD
C           - orbit right ascending node
      real*8 OANM
C           - orbit anomaly
      real*8 OAXS
C           - orbit semi-major axis
      real*8 OMOT
C           - orbit motion
C     IEPY - orbit epoch year
      integer iepy
      real*8 OEDY
C           - orbit epoch day
C
C  SUBROUTINES CALLED: LNFCH UTILITIES
C                      UNPWC - to get celestial specific info
C                      UNPWO - to get satellite orbit specific info
C
C  LOCAL:
C
C     real*8 DAS2B
      INTEGER        PCOUNT,nargs,nch,ic1,ic2,ich,jerr,idumy
      integer ichcm_ch,ichmv ! function
C
C  INITIALIZED:
C
C
C     0. Initialize to get number of parameters we were called with,
C        and set error return.
C
      NARGS = PCOUNT
      IERR = 0
C
C
C     1. Start decoding this record with the first character.
C
      ICH = 1
C
C     IAU-name, 8 characters.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN  !"too long"
        IERR = -101
        RETURN
      END IF  !"too long"
      CALL IFILL(LNAME1,1,8,oblank)
      IDUMY = ICHMV(LNAME1,1,IBUF,IC1,NCH)
C
C     Common-name, 8 characters.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN  !"too many"
        IERR = -102
        RETURN
      END IF  !"too many"
      CALL IFILL(LNAME2,1,8,oblank)
      IDUMY = ICHMV(LNAME2,1,IBUF,IC1,NCH)
C
      if (nargs.eq.5) return
C
C   Test for Satellite as opposed to celestial source and call
C        the appropriate decoding routine.
C
      JERR=0
      IF  (ichcm_ch(LNAME1,1,'ORBIT   ').NE.0) THEN  !"celestial"
        CALL UNPWC(IBUF,ILEN,JERR,LRAHMS,IRAH,IRAM,RAS,RARAD,
     .             LDSIGN,LDCDMS,IDECD,IDECM,DECS,DECRAD,
     .               EPOCH,ICH)
        IF  (JERR.NE.0) THEN  !error celestial
          IERR=JERR
          RETURN
        END IF  !error celestial
      ELSE  !"orbit"
        CALL UNPWO(IBUF,ILEN,JERR,OINC,OECC,OPER,ONOD,
     .             OANM,OAXS,OMOT,IEPY,OEDY,ICH)
        IF  (JERR.NE.0) THEN  !"error orbit"
          IERR=JERR
          RETURN
        END IF  !"error orbit"
      END IF  !celestial/orbit"
C
      RETURN
      END
