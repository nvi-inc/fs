      SUBROUTINE sunpo(MJD,UT,PI,RASUN,DECSUN)
C
C     THIS ROUTINE CALCULATES THE SUN'S RA AND DEC ON JULIAN DATE MJD
C     at time UT.
C
C 960412 nrv From DBS, based on AENA formulas. Modified to conform
C            to sked/drudg format and conventions.

      implicit none

C Input
      integer mjd ! modified Julian day
      double precision PI ! value of PI
      double precision UT ! time of day, seconds
      double precision jdate,utc,days,slon,sanom,ecllon,
     .quad,obliq,dist,sundia,conv,twopi
      integer iquad
      double precision RASUN,DECSUN
C     double precision conv,tcen,slam,oblq
C
C Old version, not accurate because it ignores the ellipticity
C of the Earth's orbit.
C     CONV = PI/180.0
C     TCEN = (MJD+2440000.D0-2415020.D0+UT/86400.d0)/36525.D0
C     SLAM = DMOD(279.697D0+36000.76892*TCEN,360.D0)*CONV
C     OBLQ = (23.452-0.01301*TCEN)*CONV
C     DECSUN = ASIN(SIN(SLAM)*SIN(OBLQ))
C     RASUN = ATAN2(SIN(SLAM)*COS(OBLQ),COS(SLAM))
C     IF (RASUN.LT.0) RASUN = RASUN + 2*PI
C     RETURN
C     END

C New version, from DBS, using formula from AENA. Abberation is ignored.
C     SUBROUTINE SUNPO(JDATE,UTC,RA,DEC,SUNDIA) 
C 
C  CALCULATE POSITION AND ANGULAR DIAMETER OF THE SUN 
C    GOOD TO <0.01 DEGREES FROM 1950 TO 2050 (1984 AENA, p. C24) 
C 
C    Convert sked's input to units required by this routine.
      jdate = mjd + 2440000 - 0.5d0
      utc=ut/86400.d0

      CONV = PI*2.d0 / 360.D0 
      twopi = 2.d0 * pi
C 
C  NUMBER OF DAYS SINCE J2000.0 ( = JD2451545.0 ) 
C 
C     DAYS = JDATE - 2451545D0 + (UTC/TWOPI) ! ?? units
      DAYS = JDATE - 2451545D0 + (UTC)  ! days
C 
C  MEAN SOLAR LONGITUDE 
C 
      SLON = 280.460D0 + 0.9856474D0*DAYS 
      SLON = DMOD(SLON,360D0) 
      IF(SLON .LT. 0D0) SLON = SLON + 360D0 
C 
C  MEAN ANOMALY OF THE SUN 
C 
      SANOM = 357.528D0 + 0.9856003D0*DAYS 
      SANOM = SANOM * CONV 
      SANOM = DMOD(SANOM,TWOPI) 
      IF(SANOM .LT. 0D0) SANOM = SANOM + TWOPI 
C 
C  ECLIPTIC LONGITUDE AND OBLIQUITY OF THE ECLIPTIC 
C 
      ECLLON = SLON + 1.915D0*DSIN(SANOM) + 0.020D0*DSIN(2D0*SANOM) 
      ECLLON = ECLLON * CONV 
      ECLLON = DMOD(ECLLON,TWOPI) 
      QUAD = ECLLON / (0.5*PI) 
      IQUAD = 1 + QUAD 
      OBLIQ = 23.439D0 - 0.0000004D0*DAYS 
      OBLIQ = OBLIQ * CONV 
C 
C  RIGHT ASCENSION AND DECLINATION 
C   (RA IS IN SAME QUADRANT AS ECLIPTIC LONGITUDE) 
C 
      RAsun = DATAN(DCOS(OBLIQ)*DTAN(ECLLON)) 
      IF(IQUAD .EQ. 2) RAsun = RAsun + PI 
      IF(IQUAD .EQ. 3) RAsun = RAsun + PI 
      IF(IQUAD .EQ. 4) RAsun = RAsun + TWOPI 
      DECsun = DASIN(DSIN(OBLIQ) * DSIN(ECLLON) ) 
C 
C  DISTANCE FROM THE EARTH AND ANGULAR DIAMETER 
C    1 A.U. = 149.60E9 METERS, SUN DIAMETER = 1.392E9 METERS 
C 
      DIST = 1.00014 - 0.01671*DCOS(SANOM) - 0.00014*DCOS(2D0*SANOM) 
      DIST = DIST * 149.60D9 
      SUNDIA = 1.392D9 / DIST 
      RETURN 
      END

