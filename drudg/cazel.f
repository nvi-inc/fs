*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
	SUBROUTINE CAZEL(ra,dec,xpos,ypos,zpos,mjd,ut,AZ,EL)
C
C   CAZEL calculates az,el given a source position, station location,
C         and time.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'

C
C     INPUT VARIABLES:
	double precision ra,dec  ! source position, radians
	double precision xpos,ypos,zpos   ! station location, meters
	double precision ut           ! UT in seconds
	integer mjd       ! modified julian date
C
C     OUTPUT VARIABLES:
	double precision az,el   ! local az,el of the source, radians
C
C     LOCAL VARIABLES:
         real SDEC,CDEC,SLAT,CLAT,SHA,CHA
C               - SIN,COS of DEC,LAT,HA
         real ARG
C               - temporary holders for trig calculations
	double precision HAD
C                   - double for internal use
	double precision ST0,FRAC
C               - sidereal time at 0h UT, UT/ST ratio, SIDEREAL TIME AT G
      real cel,sel,ha,stnlat,stnlon,azx

C  History
C  NRV 910528 created for DRUDG use reading SNAP files only
C  nrv 930412 implicit none
C 970117 nrv check for argument to ACOS being slightly greater than 1.0 and
C            set it to 1.0
C
C
C  1. First calculate the station latitude, longitude.

	stnLON = (-DATAN2(yPOS,xPOS))
	IF (stnLON.LT.0.D0) stnLON=stnLON+twopi !West lon = ATAN(y/x)
	stnLAT = DATAN2(zPOS,DSQRT((xPOS**2+yPOS**2))*(1.D0-EFLAT)**2)
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
	IF (HAD.GT.0) HAD=DMOD(HAD,twopi)
	IF (HAD.LT.0) HAD=DMOD(HAD,-twopi)
	IF (HAD.GT.PI) HAD=HAD-twopi
	IF (HAD.LT.-PI) HAD=HAD+twopi
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
