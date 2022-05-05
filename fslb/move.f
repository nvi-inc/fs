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
      subroutine move (nyri,nyrf,mo,nda,ra,d,delr,deld,dc)
C 
C  WTW'S HP VERSION OF BALL'S MOVE ROUTINE 2/8/77 
C 
C 
C  MOVE CALCULATES THE CORRECTION (DELR) IN RIGHT ASCENSION (RA) AND THE
C  CORRECTION (DELD) IN DECLINATION (D) (ALL IN RADIANS) TO BE ADDED TO THE 
C  MEAN COORDINATES FOR EPOCH NYRI (E.G. 1950) TO GIVE THE APPARENT POSITIONS 
C  OF A DATE SPECIFIED BY THE YEAR (NYRF, E.G. 1968), MONTH (MO, 1 TO 12), AND
C  DAY (NDA).  IF THE DAY-NUMBER IS KNOWN, USE IT FOR NDA AND SET MO = 1. 
C  MOVE ALSO CALCULATES THE EQUATION OF THE EQUINOXES (DC, IN MINUTES OF TIME)
C  WHICH MAY BE ADDED TO THE MEAN SIDEREAL TIME TO GIVE THE APPARENT SIDEREAL 
C  TIME (AENA-469).  DELR AND DELD CONTAIN CORRECTIONS FOR PRECESSION, ANNUAL 
C  ABERRATION, AND SOME TERMS OF NUTATION.  IF RA AND D ARE FOR THE MEAN EPOCH
C  (I.E. HALFWAY BETWEEN NYRI AND NYRF) THEN THE PRECISION OF DELR AND DELD IS
C  ABOUT 2 ARCSECONDS (SEE NEGLECTED TERMS IN ESE-44).  IF RA AND D ARE EITHER
C  OF THE END POINTS OF THE INTERVAL, THEN THE PRECISION MAY BE SOMEWHAT WORSE. 
C  AENA = THE AMERICAN EPHEMERIS AND NAUTICAL ALMANAC (THE BLUE BOOK).
C  ESE = THE EXPLANATORY SUPPLEMENT TO ABOVE (THE GREEN BOOK).
C 
      double precision ra,d,delr,deld,dc,snd,csd,tnd,csr,snr, 
     1 al,to,t,zetao,z,theta,am,an,alam,snl,csl,omega,arg,
     2 dlong,doblq,cosf,sinf,floatf,v
      cosf(v)=dcos(v) 
      sinf(v)=dsin(v) 
      floatf(ii)=dble(float(ii))
      snd=sinf(d) 
      csd=cosf(d) 
      tnd=snd/csd 
C 
      csr=cosf(ra)
      snr=sinf(ra)
C 
C  AL IS AN APPROXIMATE DAY NUMBER (I.E. THE NUMBER OF DAYS SINCE JANUARY 0 
C  OF THE YEAR NYRF). 
      al=30*(mo-1)+nda
C 
C  TO IS THE TIME FROM 1900 TO NYRI (CENTURIES) 
      to=floatf(nyri-1900)/100.0
C  T IS THE TIME FROM NYRI TO DATE (NYRF, MO, NDA) (CENTURIES)
C  (365.2421988 IS THE NUMBER OF EPHEMERIS DAYS IN A TROPICAL YEAR) 
      t=(floatf(nyrf-nyri)+al/365.2421988d0)/100.0
C  ZETAO IS A PRECESSIONAL ANGLE FROM ESE-29 (ARCSECONDS) 
      zetao=(2304.250d0+1.396*to)*t+0.302*t**2+0.018*t**3 
C  DITTO FOR Z
      z=zetao+0.791*t**2
C  AND THETA
      theta=(2004.682d0-0.853*to)*t-0.426*t**2-0.042*t**3 
C  AM AND AN ARE THE M AND N PRECESSIONAL NUMBERS (SEE AENA-50, 474) (RADIANS)
      am=(zetao+z)*4.848136811d-6 
      an=theta*4.848136811d-6 
C 
C  ALAM IS AN APPROXIMATE MEAN LONGITUDE FOR THE SUN (AENA-50) (RADIANS)
      alam=(0.985647d0*al+278.5)*0.0174532925d0 
      snl=sinf(alam)
      csl=cosf(alam)
C  DELR IS THE ANNUAL ABERRATION TERM IN RA (RADIANS) (ESE-47,48) 
C  (0.91745051 = COS(OBLIQUITY OF ECLIPTIC))
C  (-9.92413605E-5 = K = 20.47 ARCSECONDS = CONSTANT OF ABERRATION (ESE-48))
      delr=-9.92413605d-5*(snl*snr+0.91745051d0*csl*csr)/csd
     2 +am+an*snr*tnd 
C  PLUS PRECESSION TERMS (SEE AENA-50 AND ESE-38) 
C  DELD IS DITTO ABOVE IN DECLINATION 
      deld=-9.92413605d-5*(snl*csr*snd-0.91745051d0*csl*snr*snd 
     2 +0.39784993d0*csl*csd) +an*csr 
C  (0.39784993 = SIN(OBLIQUITY OF ECLIPTIC))
C 
C  THE FOLLOWING CALCULATES THE NUTATION (APPROXIMATELY) (ESE-41,45)
C  OMEGA IS THE ANGLE OF THE FIRST TERM OF NUTATION (ESE-44) (APPROXIMATE 
C  FORMULA) (DEGREES) 
      omega=259.183275d0-1934.142d0*(to+t)
C  ARG IS OMEGA CONVERTED TO RADIANS
      arg=omega*0.0174532925d0
C  DLONG IS THE NUTATION IN LONGITUDE (DELTA-PSI) (RADIANS) 
      dlong=-8.3597d-5*sinf(arg)
C  DOBLQ IS THE NUTATION IN OBLIQUITY (DELTA-EPSILON) (RADIANS) 
      doblq= 4.4678d-5*cosf(arg)
C 
C  ADD NUTATION IN RA INTO DELR (ESE-43)
      delr=delr+dlong*(0.91745051d0+0.39784993d0*snr*tnd)-csr*tnd*doblq 
C  AND DEC. 
      deld=deld+0.39784993d0 *csr*dlong+snr*doblq 
C  DC IS THE EQUATION OF THE EQUINOXES (MINUTES OF TIME) (ESE-43) 
      dc=dlong*210.264169d0 

      return
      end 
