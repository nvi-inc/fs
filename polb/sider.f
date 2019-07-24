      double precision function sider(it)
C
C CALCULATE APPARENT GREENWICH SIDERAL TIME
C
C ACCURATE TO APPROXIMATELY .1 SECONDS OF TIME
C
C WEH
C
      double precision eqofeq,sidti,fract,ut
      integer it(6)
      include '../include/dpi.i'
C
      ut =dble(float(it(1)))*.01d0 + dble(float(it(2)))
     +   +dble(float(it(3)))*60.d0 + dble(float(it(4)))*3600.d0
      iy=it(6)-1900
      mjd=julda(1,it(5),iy)
      call sidtm(mjd,sider,fract)
      call equn(iy,it(5),eqofeq)
      sider=sider+fract*ut+eqofeq
      sider=dmod(sider,DTWOPI)
      if (sider.lt.0.0d0) sider=sider+DTWOPI

      return
      end
