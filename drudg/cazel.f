	SUBROUTINE CAZEL(ra,dec,xpos,ypos,zpos,mjd,ut,AZ,EL)
C
C   CAZEL calculates az,el given a source position, station location,
C         and time.
C
      include '../skdrincl/skparm.ftni'
C
C     INPUT VARIABLES:
	real*8 ra,dec  ! source position, radians
	real*8 xpos,ypos,zpos   ! station location, meters
	real*8 ut           ! UT in seconds
	integer mjd       ! modified julian date
C
C     OUTPUT VARIABLES:
	real*8 az,el   ! local az,el of the source, radians
C
C     LOCAL VARIABLES:
         real*4 SDEC,CDEC,SLAT,CLAT,SHA,CHA
C               - SIN,COS of DEC,LAT,HA
         real*4 ARG
C               - temporary holders for trig calculations
	real*8 HAD
C                   - double for internal use
	real*8 ST0,FRAC
C               - sidereal time at 0h UT, UT/ST ratio, SIDEREAL TIME AT G
      real*4 cel,sel,ha,stnlat,stnlon,azx

C  INITIALIZED:
	real*8 ERAD,EFLAT
C               - compiled-in values of earth rad and flattening
	DATA ERAD/0.6378145D07/
	DATA EFLAT/0.3352891869D-2/
C
C  History
C  NRV 910528 created for DRUDG use reading SNAP files only
C  nrv 930412 implicit none
C 970117 nrv check for argument to ACOS being slightly greater than 1.0 and
C            set it to 1.0
C
C
C  1. First calculate the station latitude, longitude.

	stnLON = (-DATAN2(yPOS,xPOS))
	IF (stnLON.LT.0.D0) stnLON=stnLON+2.d0*PI !West lon = ATAN(y/x)
	stnLAT = (DATAN2(zPOS*ERAD**2,DSQRT((xPOS**2+yPOS**2))*
     .(ERAD**2*(1.D0-EFLAT)**2)))
C             Geocentric latitude = ATAN(z/sqrt(x^2+y^2))
C             Geodetic latitude includes earth radius and flattening

C     2. Now calculate hour angle, and then the el,az.

	CLAT = COS(STNlat)
	SLAT = SIN(STNlat)
	CALL SIDTM(MJD,ST0,FRAC)
	HAD = ST0+UT*FRAC - STNlon - ra
C       HA is Greenwich ST - west long - right ascension
	SDEC = DSIN(DEC)
	CDEC = DCOS(DEC)
	IF (HAD.GT.0) HAD=DMOD(HAD,2.D0*PI)
	IF (HAD.LT.0) HAD=DMOD(HAD,-2.D0*PI)
	IF (HAD.GT.PI) HAD=HAD-PI*2.0
	IF (HAD.LT.-PI) HAD=HAD+PI*2.0
	HA = HAD
	SHA = SIN(HA)
	CHA = COS(HA)
C
	ARG = CDEC*CLAT*CHA + SDEC*SLAT
        if (arg.gt.1.0) arg=1.0
        if (arg.lt.-1.0) arg=-1.0
	EL = PI/2.0 - ACOS(ARG)
	SEL = SIN(EL)
	CEL = COS(EL)
	ARG = (-SLAT/(CLAT*CEL))*(SEL-SDEC/SLAT)
	IF (ABS(HA).LT.1.D-3.AND.ARG.LT.0.0) ARG=-1.0
	IF (ABS(HA).LT.1.D-3.AND.ARG.GE.0.0) ARG=+1.0
        if (arg.gt.1.0) arg=1.0
        if (arg.lt.-1.0) arg=-1.0
	AZ = ACOS(ARG)
	AZX = -CDEC*SHA/CEL
	IF (AZX.LT.0) AZ = 2.0*PI - AZ

	return
	end
