      subroutine mjd2yrDoy(mjd,iyear,idoy)
! History
! 2019Jun10  JMG. Revised to use non-NR routines
! Pass
      integer*4 mjd
! Return 
      integer iyear,idoy     ! idoy=iday of year. 
! functions
      integer iday_of_year
! local
      integer imon,iday
      integer*4 mjd_temp
      integer*4 jday
! convert to mon,day,year
      jday=mjd+2440000
      call gdate(jday,iyear,imon,iday)
      idoy=iday_of_year(iyear,imon,iday) 
      return
      end



