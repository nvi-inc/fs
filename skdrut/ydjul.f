      SUBROUTINE ydjul(IYEAR,IDAY,FJD)
C
C        *YDJUL CONVERTS JULIAN DATE @ MIDNIGHT TO YEAR AND DAY OF YEAR. *
C        * COPIED FROM DOUG'S  #$%!   MDYJL *
C        * NRV 810331                       *
C Input: FJD
C Output: IYEAR, IDAY
C 981113 nrv Y2K. Commented out do-nothing statements. Return
C            a 4-digit year with the century depending on the
C            year.
C
      implicit none
      integer iyear,iday
      real*8 FJD,xjd
      integer nyr,ic,inyr
C
C**** XJD = DAYS SINCE 0 JANUARY, 1600
      XJD = FJD - 2305447.0D0 + 0.5D0
      NYR = XJD/365.
C**** IC = NUMBER OF CENTURIES SINCE 0 JANUARY, 1600
   16 IC = NYR/100
C     DAYS DUE TO LEAP YEARS
      INYR = XJD - NYR*365.0
      IDAY = INYR - (NYR-1)/4 + (NYR + 99)/100 - (NYR + 399)/400 - 1
      IF(IC .NE.0) GO TO 20
      IF(NYR.NE.0) GO TO 20
      IDAY = IDAY + 1
   20 IF(IDAY .GT. 0) GO TO 23
      NYR = NYR - 1
      GO TO 16
C**** IYEAR (O THRU 99) YEAR OF THE CENTURY
   23 IYEAR = NYR - IC * 100
      if (iyear.ge.00.and.iyear.le.49) iyear = iyear + 2000
      if (iyear.ge.50.and.iyear.le.99) iyear = iyear + 1900
C These two statements do nothing. Commented out 981113.
C     ITIME = IC - 3
C     NYR = IYEAR
      RETURN
      END
