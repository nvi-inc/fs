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
      SUBROUTINE CVPOS(NSOR,ISTN,MJD,UT,AZ,EL,HA,DC,X30,Y30,X85,Y85,
     .                 KUP)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C   CVPOS converts source ra and dec into az,el,ha,x, and y; or satellite
C         elememts into the same plus dec.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
C
C  INPUT VARIABLES:
      integer nsor,istn,mjd
C        NSOR   - Source index number into DB arrays
C        ISTN   - Station index number into DB arrays
C        MJD    - Modified Julian date (from JULDA)
      real*8 UT ! UT for which positions requested

C  OUTPUT VARIABLES:
      real*4 az,el,ha,dc,x30,y30,x85,y85
C        AZ,EL,HA,DC,X30,Y30,X85,Y85 - az,el,ha,dc,and x,y at input date and time
      LOGICAL KUP ! TRUE if source is above limits at MJD,UT
C
C   COMMON BLOCKS USED
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
C
C     LOCAL VARIABLES:
      real*4 slat,clat,sha,cha,saz,sel,cel,azx,
     .caz,arcd,sunaz,sunel,x,arg,sunarc
      integer i
      real eli
C        SDEC,CDEC,SLAT,CLAT,SHA,CHA
C               - SIN,COS of DEC,LAT,HA
C        ARG,SAZ,DEC
C               - temporary holders for trig calculations
      real*8 HAD!AZD,ELD
C                   - double for internal use
      real*8 ST0,FRAC
C               - sidereal time at 0h UT, UT/ST ratio, SIDEREAL TIME AT G
      real*8 OINC,OECC,OPER,ONOD,OANM,OAXS,OMOT,OEDY,RANGE
C          OINC  - orbit inclination
C          OECC  - orbit eccentricity
C          OPER  - orbit arguement of perigee
C          ONOD  - orbit right ascending node
C          OANM  - orbit mean anomaly
C          OAXS  - orbit semi-major axis
C          OMOT  - orbit mean motion
C          OEDY  - orbital element's epoch day and fraction
C          RANGE - dummy variable to hold range.
C          IOEY  - ORBIT ELEMENT'S EPOCH YEAR
      integer ioey,norb
      real*8 ALAT,ALON
C          ALAT  - real*8 latitude for XAT call.
C          ALON  - real*8 longitude for XAT call.
C          RANGE - real*8 range(km) for XAT call.
      real*8 DEC,SDEC,CDEC
      real*4 acos,asin
C        ASIN,X- statement function for ARSIN, argument
C        ACOS,X- statement function for ARCOS, argument
C     sunaz, sunel - sun's az, el returned from sunazel routine
C
C   PROGRAMMER: NRV
C     WHO  WHEN    WHAT
C     NRV  830423  Add x,y calculations.
C     WEH  830523  Add satellites, add DC to arguments.
C     NRV  880315  DE-COMPC'D
C     GAG  881221  ADDED HORIZON AND COORDINATE MASK CHECK WRITTEN BY NRV
C     NRV  900125  Added type 6 = SEST with 30 degree sun avoidance
C     NRV  900208  Reversed XYEW and XYNS for schedule dates after
C                  April 1, 1990 (this corrects the erroneous designations)
C     NRV  900309  Added call to SUNAZEL for SEST limit check
C     931012 nrv Remove statement functions for acos, asin//REPLACED
C                Remove DMOD and check HA for 2PI
C     940804 nrv Changed limit on horizon check to i<nhorz because the
C                value is checked between (i) and (i+1).
C 960223 nrv Change to using (az,el) points actually on the horizon
C            and interpolating between the line segments. Keep the
C            coordinate mask unchanges.
C
C
C     1. Define the statement function ACOS.
C
      ACOS(X) = ATAN2(SQRT(ABS(1.0-X*X)),X)
      ASIN(X) = ATAN2(X,SQRT(ABS(1.0-X*X)))
C
C
C     2. Now calculate hour angle and dec, and sin/cos.
C
      IF  (NSOR.LE.NCELES) THEN  !
        CALL SIDTM(MJD,ST0,FRAC)
        HAD = ST0+UT*FRAC - STNPOS(1,ISTN) - SORPDA(1,NSOR)
        DEC=SORPDA(2,NSOR)
      ELSE  !
        NORB=NSOR-NCELES
        OINC=SATP50(1,NORB)
        OECC=SATP50(2,NORB)
        OPER=SATP50(3,NORB)
        ONOD=SATP50(4,NORB)
        OANM=SATP50(5,NORB)
        OAXS=SATP50(6,NORB)
        OMOT=SATP50(7,NORB)
        IOEY=ISATY(NORB)
        OEDY=SATDY(NORB)
C
        ALON=STNPOS(1,ISTN)
        ALAT=STNPOS(2,ISTN)
        CALL XAT(OINC,OECC,OPER,ONOD,OANM,OAXS,OMOT,IOEY,OEDY,
     .                   MJD,UT,ALAT,ALON,HAD,DEC,RANGE)
        CALL XAT(OINC,OECC,OPER,ONOD,OANM,OAXS,OMOT,IOEY,OEDY,
     .                   MJD,UT,ALAT,ALON,HAD,DEC,RANGE)
      END IF  !

      SDEC = DSIN(DEC)
      CDEC = DCOS(DEC)
      DC=SNGL(DEC)
C
C                   HA is Greenwich ST - west long - right ascension
C     HA is guaranteed to be within +/- 4PI
      IF (HAD.GT.0) HAD=DMOD(HAD,TWOPI)
      IF (HAD.LT.0) HAD=DMOD(HAD,TWOPI)
C     IF (HAD.GT.2.0*PI) HAD=HAD-PI*2.0
C     IF (HAD.LT.-2.0*PI) HAD=HAD+PI*2.0
      IF (HAD.GT.PI) HAD=HAD-TWOPI
      IF (HAD.LT.-PI) HAD=HAD+TWOPI
      if (had.gt.pi.or.had.lt.-pi) then
        write(7,*) 'CVPOS: HA out of range',had
        stop
      endif
      HA = HAD
      SHA = SIN(HA)
      CHA = COS(HA)
C

C     These calculations needed for az/el and XY mounts
        CLAT = COS(STNPOS(2,ISTN))
        SLAT = SIN(STNPOS(2,ISTN))
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

C     These calculations needed for XY mounts
        SAZ = SIN(AZ)
        CAZ = COS(AZ)
        X85 = ATAN2(SAZ*CEL,SEL)
        Y85 = ASIN(CEL*CAZ)
        Y30 = ASIN(CEL*SAZ)
        X30 = -ATAN2(CEL*CAZ,SEL)

        IF (IAXIS(ISTN).EQ.5) THEN ! Richmond
          AZ=AZ-.20944E-2
          SAZ=SIN(AZ)
          CAZ=COS(AZ)
          CLAT=DCOS(.6817256D0)
          SLAT=DSIN(.6817256D0)
          HA=-ATAN2(CEL*SAZ,SEL*CLAT-CEL*CAZ*SLAT)
          IF (HA.LT.-PI) HA=HA+TWOPI
          IF (HA.GT.PI) HA=HA-TWOPI
          DC=ASIN(CEL*CAZ*CLAT+SEL*SLAT)
        END IF ! Richmond
C                 This is the special case of Richmond
C
C
C     3.  Now check the computed az,el,ha,x,y against the telescopes
C         limit stops.
C
      KUP = .TRUE.
C         For ha/dec mounts, check hour angle,
C         declination, and elevation limits:
C         (1 = ha/dec, 5 = Richmond)
      IF (IAXIS(ISTN).EQ.1.OR.IAXIS(ISTN).EQ.5) THEN
        KUP=((HA.GT.STNLIM(1,1,ISTN)).AND.
     .       (HA.LT.STNLIM(2,1,ISTN)).AND.
     .       (DC.GT.STNLIM(1,2,ISTN)).AND.
     .       (DC.LT.STNLIM(2,2,ISTN)))
        IF (NCORD(ISTN).GT.0) THEN
          I=1
          DO WHILE(I.LE.NCORD(ISTN).AND.
     .      (DC.LT.CO1MASK(I,ISTN).OR.DC.GE.CO1MASK(I+1,ISTN)))
            I=I+1
          ENDDO
          KUP=KUP.AND.ABS(HA).LE.CO2MASK(I,ISTN)
        ENDIF
C         For x,y mounts with fixed axis oriented EW, check x and y
C      (2=XYEW)
      ELSE IF (IAXIS(ISTN).EQ.2) THEN
        KUP=((X30.GT.STNLIM(1,1,ISTN)).AND.
     .       (X30.LT.STNLIM(2,1,ISTN)).AND.
     .       (Y30.GT.STNLIM(1,2,ISTN)).AND.
     .       (Y30.LT.STNLIM(2,2,ISTN)))
        IF (NCORD(ISTN).GT.0) THEN
          I=1
          DO WHILE(I.LE.NCORD(ISTN).AND.
     .      (X30.LT.CO1MASK(I,ISTN).OR.X30.GE.CO1MASK(I+1,ISTN)))
            I=I+1
          ENDDO
          KUP=KUP.AND.Y30.GE.CO2MASK(I,ISTN)
        ENDIF
C         For az/el mounts, check elevation only (azimuth cable
C         wrap is checked later), for both limits:
C       (3 = AZEL)  (check 6=SEST and 7=ALGO here too)
      ELSE IF (IAXIS(ISTN).EQ.3.or.iaxis(istn).eq.6.or.
     .         iaxis(istn).eq.7) THEN
        KUP=((EL.GT.STNLIM(1,2,ISTN)).AND.
     .       (EL.LT.STNLIM(2,2,ISTN)))
        IF (NCORD(ISTN).GT.0) THEN
          I=1
          DO WHILE(I.LE.NCORD(ISTN).AND.
     .      (AZ.LT.CO1MASK(I,ISTN).OR.AZ.GE.CO1MASK(I+1,ISTN)))
            I=I+1
          ENDDO
          KUP=KUP.AND.EL.GE.CO2MASK(I,ISTN)
        ENDIF
C         For x,y mounts with fixed axis oriented NS, check x and y
C       (4 = XYNS)
      ELSE IF (IAXIS(ISTN).EQ.4) THEN
        KUP=((X85.GT.STNLIM(1,1,ISTN)).AND.
     .       (X85.LT.STNLIM(2,1,ISTN)).AND.
     .       (Y85.GT.STNLIM(1,2,ISTN)).AND.
     .       (Y85.LT.STNLIM(2,2,ISTN)))
        IF (NCORD(ISTN).GT.0) THEN
          I=1
          DO WHILE(I.LE.NCORD(ISTN).AND.
     .      (X85.LT.CO1MASK(I,ISTN).OR.X85.GE.CO1MASK(I+1,ISTN)))
            I=I+1
          ENDDO
          KUP=KUP.AND.Y85.GE.CO2MASK(I,ISTN)
        ENDIF
      ENDIF
C     For the SEST antenna, check sun distance
C        (6 = SEST)
      IF (IAXIS(ISTN).eq.6) then
C       ** NOTE ** This check is not required if the sun has
C       set at SEST!  Compute sun's az,el for the current time.
        call sunazel(istn,mjd,ut,sunaz,sunel)
        if (sunel.gt.0.d0) then !sun is up, check distance
          arcd = sunarc(nsor,mjd,ut)
          KUP=KUP.and.(arcd.ge.50.0)
C  gag changed 30.0 to 50.0 on 900410
        endif
      endif
C     Check for station elevation limit, set within SKED
      KUP=KUP.AND.EL.GT.STNELV(ISTN)
C     Now check horizon mask for stations that have one.
      IF (NHORZ(ISTN).GT.0) THEN
        I=1
        DO WHILE(I.LT.NHORZ(ISTN).AND.
     .    (AZ.LT.AZHORZ(I,ISTN).OR.AZ.GE.AZHORZ(I+1,ISTN)))
          I=I+1 ! find AZ between i and i+1
        ENDDO
        if (.not.klineseg(istn)) then ! use step functions
          eli=elhorz(i,istn)
        else ! interpolate horizon mask line segment end points
          if (azhorz(i+1,istn).eq.azhorz(i,istn)) then ! inf slope
            eli=elhorz(i,istn) ! pick one
          else
            eli=((elhorz(i+1,istn)-elhorz(i,istn))/
     .      (azhorz(i+1,istn)-azhorz(i,istn)))
     .      *(az-azhorz(i,istn)) + elhorz(i,istn)
          endif ! inf slope
        endif
        KUP=KUP.AND.EL.GE.eli
      ENDIF
C
      RETURN
      END
