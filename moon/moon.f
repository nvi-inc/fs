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
      program moon
C
      double precision utfrac,ra,dec,
     .dasin,x,dattim,range,gst,stm,frac,
     .rearth,xm,ym,zm,singst,cosgst,xme,yme,zme,xsm,ysm,zsm,
     .rsm,diam,had,gdlat,gdlon,xs,ys,zs,rate,gdhei
C
C  INPUT VARIABLES
C
      integer*2 ibufi(24)
      integer*4 ip(5)
C
C  OUTPUT VARIABLES
C
      integer*2 ibufo(8)
C
C  LOCAL VARIABLES
C
      integer it(6),get_buf
C
      include '../include/dpi.i'
C
C  INCOMING  BUFFER  24 WORDS
C
      equivalence (ibufi(1),gdlat),
     +            (ibufi(5),gdlon),
     +            (ibufi(9),gdhei),
     +            (ibufi(13),it)
C
C  OUTGOING BUFFER 8 WORDS
C
      equivalence (ibufo(1),ra),
     +            (ibufo(5),dec)
C
C INITIALIZED VARIABLES
      data rearth,rate /6378160d0,1.002737909d0/
C
C   HISTORY:
C  DATE   WHO  WHAT
C 841120  MWH  CREATED
C 850426  WEH  fixed precision of HEIGHT argument to GD2XY
C              add seconds to UTFRAC
C
C Statement function for double precision arcsin
      dasin(x) = datan2(x,dsqrt(dabs(1d0-x*x)))
C
C  1. Get command, initialize date/time info
C
      call setup_fscom
1     continue
      call wait_prog('moon ',ip)
      idum = get_buf(ip,ibufi,-48,idum,idum)
C
      call gd2xy(gdlon,gdlat,gdhei ,xs,ys,zs)
      sinphi = dsin(gdlat)
      cosphi = dcos(gdlat)
      iy = it(6)-1900
      jd = julda(1,it(5),iy)
      utfrac = (it(2)+60d0*it(3)+3600d0*it(4))/86400.d0
      utc = utfrac*dtwopi
      call sidtm(jd,stm,frac)
      gst = stm + utc*rate
      dattim = jd + 2439999.5d0 + utfrac
      call moonp(dattim,ra,dec,range)
      ra = ra * dtwopi /24d0
      ra = dmod(ra,dtwopi)
      if (ra.lt.0d0) ra = ra + dtwopi
      dec = dec * deg2rad
      range = range * rearth
      xm = range * dcos(dec) * dcos(ra)
      ym = xm * dtan(ra)
      zm = range * dsin(dec)
      singst = dsin(gst)
      cosgst = dcos(gst)
      xme = xm * cosgst + ym * singst
      yme = -xm * singst + ym * cosgst
      zme = zm
C
C  Get vector from station to moon
C
      xsm = xme - xs
      ysm = yme - ys
      zsm = zme - zs
      rsm = dsqrt(xsm*xsm + ysm*ysm + zsm*zsm)
      diam = 3.476d6 / rsm
      diam = diam * rad2deg
C
C  Get apparent HA and DEC from station-moon vector and AZ and
C   EL from HA and DEC
C
      dec = dasin(zsm / rsm)
      had = gdlon - datan2(ysm,xsm)
      had = dmod(had,dtwopi)
      if (had.gt.dpi) had = had - dtwopi
      if (had.lt.-dpi) had = had + dtwopi
      ra = gst + gdlon - had
      ra = dmod(ra,dtwopi)
      if (ra.lt.0d0) ra = ra + dtwopi
C
      ip(1)=0
      call put_buf(ip(1),ibufo,-16,'  ','  ')
      goto 1
C
      end
