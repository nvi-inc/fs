      LOGICAL FUNCTION KCONT(UT,DUR,ISOR,IST,LCABL,MJD)
C
C     This checks that an observation is continuous, i.e. that it
C     doesn't end on a different part of the cable from which it began.
C     KCONT is returned TRUE if the observation is continuous.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
C
C  INPUT:
      real*8 UT
      real*4 dur
      integer isor,ist,mjd
      integer*2 lcabl
C     UT - Start time for the observation
C     DUR - Duration of the observation
C     ISOR - Source number
C     IST - Station number
C     LCABL - Cable wrap for this observation (=2HC ,2HW ,2H  )
C     MJD - Julian day of observation
C
C  LOCAL:
      LOGICAL KUP
      real*4 az1,el1,ha1,dec1,x1,y1,x2,y2,az2,el2,ha2,dec2,
     .delaz,az2c
      integer ichcm_ch
C
C  COMMON:
      include '../skdrincl/statn.ftni'
C
C   PROGRAMMER: MAH  811125
C    MODIFICATIONS:
C    DATE   WHO    CHANGES
C    830524 WEH    ADD DEC TO CVPOS CALLS
C    880315 NRV    DE-COMPD'C
C    930225 nrv implicit none
C 001226 nrv Changed  comment on definition of DUR: it is the
C            duration not the stop time of the observation.
C
C
C     First work out the source position at UT and the position at UT+DUR.
C     Find delta-az
C     Check that AZ1+delAZ is on the same cable wrap
C     Return KCONT = FALSE if the observation is not continuous
C     If you don't have an AZ-EL antenna return immediately with KCONT=TRUE
C
C
      IF (IAXIS(IST).EQ.3.or.iaxis(ist).eq.7.or.iaxis(ist).eq.6) 
     .GOTO 100
      KCONT=.TRUE.
      RETURN
100   CONTINUE
      CALL CVPOS(ISOR,IST,MJD,UT,AZ1,EL1,HA1,DEC1,X1,Y1,X1,Y1,KUP)
      CALL CVPOS(ISOR,IST,MJD,UT+DUR,AZ2,EL2,HA2,DEC2,X2,Y2,X2,Y2,KUP)
C
      DELAZ = AZ2-AZ1
      IF (DELAZ.GT.PI) DELAZ = -(TWOPI-DELAZ)
      IF (DELAZ.LT.-PI) DELAZ = TWOPI+DELAZ
C
      IF(AZ1.LT.STNLIM(1,1,IST)) AZ1=AZ1+TWOPI
      IF(ichcm_ch(LCABL,1,'HC').eq.0) AZ1=AZ1+TWOPI
      IF(AZ1.GT.STNLIM(2,1,IST)) AZ1=AZ1-TWOPI
C
      AZ2C = AZ1+DELAZ
C
C  Check whether we cross into ambiguous section during observation
C
      IF (AZ2C.LE.STNLIM(2,1,IST).AND.AZ2C.GE.STNLIM(1,1,IST)
     .+TWOPI.AND.ichcm_ch(LCABL,1,'  ').eq.0) THEN  !set end of observation cable wrap
        IF (DELAZ.GT.0.) call char2hol('C ',LCABL,1,2)
        IF (DELAZ.LT.0.) call char2hol('W ',LCABL,1,2)
      ENDIF 
      KCONT = .TRUE.
      IF (AZ2C.LT.STNLIM(1,1,IST)) KCONT = .FALSE.
      IF (AZ2C.GT.STNLIM(2,1,IST)) KCONT = .FALSE.
C
      RETURN
      END
