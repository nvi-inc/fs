      integer FUNCTION julda(IMONTH,IDAY,IYEAR)
      implicit none
      INTEGER   IMONTH,IDAY,IYEAR,IYR,IYR1,iyin
      INTEGER MONTOT(12)
      DATA      MONTOT    /0,31,59,90,120,151,181,212,243,273,304,334/
C           IDAY  =DAY OF MONTH    (BETWEEN 1 AND 31)
C           IMONTH=MONTH           (BETWEEN 1 AND 12)
C           IYEAR =YEAR SINCE 1900 (NEGATIVE BEFORE 1900)
C
C     M.E.ASH   OCT 1966    DETERMINATION OF JULIAN DAY NUMBER
C     MODIFIED FOR 21MX BY CAK
C     RETURNS JD-2440000
C     FROM GIVEN MONTH,DAY AND YEAR SINCE 1900 (GREGORIAN CALENDAR)
C     VALID FROM 1601 TO 2099
C     NOT QUITE, ANYMORE, DUE TO THE LIMITED INTEGER SIZE IN THE
C     21MX COMPUTER (+- 32767)
CY2K  980804 nrv Add 100 to input year if it's 0 to 50. Use IYIN
C                in this routine so that IYEAR is not modified.
      iyin = iyear
C     This is not correct. The input is years since 1900. Don't change it.
C     if (iyear.ge.0.and.iyear.lt.50) iyin=iyear+100
      IYR1  =0
      IYR   =IYIN/4
      IF(IYIN) 3,21,7
    3 IYR1  =IYIN/100
      IF(IYIN.NE.IYR1*100) GO TO 7
      IF(IMONTH.GT.2) IYR1=IYR1+1
    7 IF(IYIN.NE.IYR*4) GO TO 21
      IF(IYR) 11,21,15
   11 IF(IMONTH.LE.2) GO TO 21
      IYR   =IYR+1
      GO TO 21
   15 IF(IMONTH.GT.2)    GO TO 21
      IYR   =IYR-1
   21 JULDA =(-24980 +365*IYIN)+(MONTOT(IMONTH)+IDAY+IYR-IYR1)
      RETURN
      END
