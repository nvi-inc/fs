      SUBROUTINE sunazel(ISTN,MJD,UT,AZ,EL)
C
C   SUNEL converts the sun's ra and dec into az, el
C
      include '../skdrincl/skparm.ftni'
      include "../skdrincl/constants.ftni"
C
C     INPUT VARIABLES:
      integer istn,mjd
C        ISTN   - Station index number into DB arrays
C        MJD    - Modified Julian date (from JULDA)
      real*8 UT
C               - UT for which positions requested
C
C     OUTPUT VARIABLES:
      real*4 az,el
C        AZ,EL - az,el at input date and time, radians
C
C   COMMON BLOCKS USED
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
C
C     LOCAL VARIABLES:
      real*8 slat,clat,sha,cha,arg
      real*4 dc,ha,sel,cel,azx
C        SDEC,CDEC,SLAT,CLAT,SHA,CHA
C               - SIN,COS of DEC,LAT,HA
C        ARG,DEC
C               - temporary holders for trig calculations
      real*8 HAD!AZD,ELD
C                   - double for internal use
      real*8 ST0,FRAC
C               - sidereal time at 0h UT, UT/ST ratio, SIDEREAL TIME AT G
      real*8 DEC,SDEC,CDEC
      real*8 rasun,decsun
C        ASIN,X- statement funcion for ARSIN, argument
C        ACOS,X- statement funcion for ARCOS, argument
      real*4 acos,asin,x
C
C   PROGRAMMER: NRV
C     WHO  WHEN    WHAT
C     NRV  900309  Created
C     nrv  930225  implicit none
C     nrv  950329  Removed duplicate declaration of FRAC.
C
C     1. Define the statement function ACOS, since HP Fortran does not
C        have it.  Then calculate the trig functions which are needed
C        more than once.
C
      ACOS(X) = ATAN2(SQRT(ABS(1.0-X*X)),X)
      ASIN(X) = ATAN2(X,SQRT(ABS(1.0-X*X)))
      CLAT = COS(STNPOS(2,ISTN))
      SLAT = SIN(STNPOS(2,ISTN))
C
C
C     2. Now calculate hour angle, get or calculate get as appropriate,
C        and then the el,az and x,y angles.
C
        call sunpo(mjd,ut,pi,rasun,decsun)
        CALL SIDTM(MJD,ST0,FRAC)
        HAD = ST0+UT*FRAC - STNPOS(1,ISTN) - rasun
        DEC=decsun
      SDEC = DSIN(DEC)
      CDEC = DCOS(DEC)
C
      DC=SNGL(DEC)
C
C                   HA is Greenwich ST - west long - right ascension
      IF (HAD.GT.0) HAD=DMOD(HAD,2.D0*PI)
      IF (HAD.LT.0) HAD=DMOD(HAD,-2.D0*PI)
      IF (HAD.GT.PI) HAD=HAD-PI*2.0
      IF (HAD.LT.-PI) HAD=HAD+PI*2.0
      HA = HAD
      SHA = SIN(HA)
      CHA = COS(HA)
C
      ARG = CDEC*CLAT*CHA + SDEC*SLAT
      EL = PI/2.0 - ACOS(ARG)
      SEL = SIN(EL)
      CEL = COS(EL)
      ARG = (-SLAT/(CLAT*CEL))*(SEL-SDEC/SLAT)
      IF (ABS(HA).LT.1.D-3.AND.ARG.LT.0.0) ARG=-1.0
      IF (ABS(HA).LT.1.D-3.AND.ARG.GE.0.0) ARG=+1.0
      AZ = ACOS(ARG)
      AZX = -CDEC*SHA/CEL
      IF (AZX.LT.0) AZ = 2.0*PI - AZ
C
      RETURN
      END
