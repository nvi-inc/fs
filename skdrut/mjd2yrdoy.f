      subroutine mjd2yrDoy(mjd,iyear,iday)
      integer*4 mjd
      integer iyear,iday
! functions
      integer*4 julda
! local
      integer mon
      integer*4 mjd_temp
      integer*4 jday
! convert to mon,day,year
      jday=mjd+2440000
      call caldat(jday,mon,iday,iyear)
      mjd_Temp=JULDA(1,1,iyear-1900)
      iday=mjd-mjd_temp+1
      return
      end



