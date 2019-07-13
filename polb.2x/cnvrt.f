      subroutine cnvrt(imode,ain1,ain2,out1,out2,it,alat,wlong)
C
C  INPUT:
C
C     IMODE - specifies input and output coordinate systems
C              IMODE     Input      Output
C              -----     -----      ------
C                1       RA/DEC      AZ/EL
C                2       AZ/EL       RA/DEC
C                3       RA/DEC      X/Y NS
C                4       X/Y NS      AZ/EL
C                5       AZ/EL       X/Y NS
C                6       X/Y NS      HA/DEC
C                7       X/Y NS      RA/DEC
C                8       HA/DEC      X/Y NS
C                9       HA/DEC      AZ/EL
C               10       AZ/EL       HA/DEC
C
C     AIN1 - first input coordinate
C     AIN2 - second input coordinate
C
C  OUTPUT:
C
C     OUT1 - first output coordinate
C     OUT2 - second output coordinate
C
      implicit double precision (a-h,o-z)
      double precision sidt,sider,had,tlst
      real dut
      dimension it(6)
C
      include '../include/dpi.i'
C
      dasin(x) = datan2z(x,dsqrt(dabs(1.-x*x)))
      dacos(x)=datan2z(dsqrt(dabs(1.-x*x)),x)
C
      sidt=sider(it)
      goto 10
C
      entry cnvrt2(imode,ain1,ain2,out1,out2,it,dut,alat,wlong)
      sidt=sider2(it,dut)
C
 10   continue
      slat = dsin(alat)
      clat = dcos(alat)
      sin1 = dsin(ain1)
      sin2 = dsin(ain2)
      cin1 = dcos(ain1)
      cin2 = dcos(ain2)
      tlst=sidt-wlong
      had = tlst-ain1
      if (had.gt.0.d0) had=dmod(had,dtwopi)
      if (had.lt.0.d0) had=dmod(had,-dtwopi)
      if (had.lt.-dpi) had=had+dtwopi
      if (had.gt.dpi) had=had-dtwopi
      ha=had
      sha=dsin(ha)
      cha=dcos(ha)
C
      goto (110,130,150,170,190,210,230,250,270,290) imode
C
C  1. RA/DEC --> AZ/EL
C
110   out2=dasin(slat*sin2+clat*cin2*cha)
      out1=datan2z(-cin2*sha,clat*sin2-slat*cin2*cha)
      if (out1.lt.0.) out1=out1+dtwopi
      goto 900
C
C  2. AZ/EL --> RA/DEC
C
130   ha=-datan2z(cin2*sin1,sin2*clat-cin2*cin1*slat)
      out1=tlst-ha
      if (out1.lt.0.) out1=out1+dtwopi
      if (out1.gt.dtwopi) out1=out1-dtwopi
      out2=dasin(cin2*cin1*clat+sin2*slat)
      goto 900
C
C  3. RA/DEC --> X/Y NS
C
150   out1=datan2z(-cin2*sha,slat*sin2+clat*cin2*cha)
      out2=dasin(clat*sin2-slat*cin2*cha)
      goto 900
C
C  4. X/Y NS --> AZ/EL
C
170   out1=datan2z(sin1*cin2,sin2)
      if (out1.lt.0) out1=out1+dtwopi
      out2=dasin(cin2*cin1)
      goto 900
C
C  5. AZ/EL  --> XY NS
C
190   continue
      out1=datan2z(cin2*sin1,sin2)
      out2=dasin(cin2*cin1)
      goto 900
C
C  6. X/Y  NS --> HA/DEC
C
210   continue
      out1=-datan2z(cin2*sin1,cin2*cin1*clat-sin2*slat)
      out2=dasin(sin2*clat+cin2*cin1*slat)
      goto 900
C 
C   7. X/Y NS --> RA/DEC  
C
230   continue
      ha=-datan2z(cin2*sin1,cin2*cin1*clat-sin2*slat)
      out1=tlst-ha
      if (out1.lt.0.0) out1=out1+dtwopi
      if (out1.gt.dtwopi) out1=out1-dtwopi
      out2=dasin(sin2*clat+cin2*cin1*slat)
      goto 900
C
C  8. HA/DEC --> X/Y NS
C
250   out1=datan2z(-cin2*sin1,slat*sin2+clat*cin2*cin1)
      out2=dasin(clat*sin2-slat*cin2*cin1)
      goto 900
C
C  9. HA/DEC --> AZ/EL
C
270   out2=dasin(slat*sin2+clat*cin2*cin1)
      out1=datan2z(-cin2*sin1,clat*sin2-slat*cin2*cin1)
      if (out1.lt.0.) out1=out1+dtwopi
      goto 900
C
C 10. AZ/EL --> HA/DEC
C
290   out1=-datan2z(cin2*sin1,sin2*clat-cin2*cin1*slat)
      if (out1.lt.-dpi) out1=out1+dtwopi
      if (out1.gt.dpi) out1=out1-dtwopi
      out2=dasin(cin2*cin1*clat+sin2*slat)
      goto 900
C
900   continue

      return
      end
