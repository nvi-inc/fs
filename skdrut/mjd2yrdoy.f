      subroutine mjd2yrDoy(mjd,iyear,iday)
      integer*4 mjd
      integer iyear,iday
! functions
      integer*4 julda
! local
      integer mm,iday,iyear
      integer*4 mjd_temp

      call caldat(mjd,mm,iday,iyear)
      mjd_temp=julda(mm

      mjd_Temp=JULDA(1,1,iyear-1900)
      iday=mjd-mjd_temp+1
      return
      end



