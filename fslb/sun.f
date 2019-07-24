      subroutine sun(ra,dec,it) 
C 
      include '../include/dpi.i'
C
      double precision,conv,utc,utfrac,ra,dec,days,slon,
     .sanom,ecllon,dasin,quad,obliq,x 
C 
      dimension it(6) 
C 
C INITIALIZED VARIABLES 
C 
C   HISTORY:
C  DATE   WHO  WHAT 
C 841120  MWH  CREATED
C 850426  WEH  GET JULIAN DATE RIGHT, ADD SECONDS TO UTFRAC 
C 
C Statement function for double precision arcsin
      dasin(x) = datan2(x,dsqrt(dabs(1d0-x*x)))
C 
C  1. Get command, initialize date/time info
C 
      conv = DTWOPI/360d0
C 
      iy = it(6)-1900 
      jd = julda(1,it(5),iy)
      utfrac = (it(2)+60d0*it(3)+3600d0*it(4))/86400.d0 
      utc = utfrac*DTWOPI
C 
C  2. Compute position of the sun 
C 
C  # of days since J2000 (=JD11545) 
C 
      days = jd-11545.5d0+utc/DTWOPI 
C 
C  Mean solar longitude 
C 
      slon = 280.46d0 + .9856474d0 * days 
      slon = dmod(slon,360d0) 
      if (slon.lt.0d0) slon = slon + 360d0
C 
C  Mean anomaly of the sun
C 
      sanom = 357.528d0 + .9856003d0 * days 
      sanom = sanom * conv
      sanom = dmod(sanom,DTWOPI) 
      if (sanom.lt.0d0) sanom = sanom + DTWOPI 
C 
C  Ecliptic longitude and obliquity of the ecliptic 
C 
      ecllon = slon + 1.915d0 * dsin(sanom) + .02d0 * dsin(2d0*sanom) 
      ecllon = ecllon * conv
      ecllon = dmod(ecllon,DTWOPI) 
      quad = ecllon/(.5*DPI)
      iquad = 1 + quad
      obliq = 23.439d0 - 4.d-7 * days 
      obliq = obliq * conv
C 
C  RA and DEC (RA is in the same quadrant as ecliptic longitude 
C 
      ra = datan(dcos(obliq) * dtan(ecllon))
      if (iquad.eq.2) ra = ra + DPI 
      if (iquad.eq.3) ra = ra + DPI 
      if (iquad.eq.4) ra = ra + DTWOPI 
      dec = dasin(dsin(obliq) * dsin(ecllon)) 
C 
      return
      end 
