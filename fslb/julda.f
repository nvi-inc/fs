      integer function julda(imonth,iday,iyear) 

C     M.E.ASH   OCT 1966    DETERMINATION OF JULIAN DAY NUMBER
C     MODIFIED FOR 21MX BY CAK
C     RETURNS JD-2440000
C     FROM GIVEN MONTH,DAY AND YEAR SINCE 1900 (GREGORIAN CALENDAR) 
C     VALID FROM 1601 TO 2099 
C     NOT QUITE, ANYMORE, DUE TO THE LIMITED INTEGER SIZE IN THE
C     21MX COMPUTER (+- 32767)
      integer   imonth,iday,iyear,iyr,iyr1
      integer montot(12)
      data montot /0,31,59,90,120,151,181,212,243,273,304,334/
C           IDAY  =DAY OF MONTH    (BETWEEN 1 AND 31) 
C           IMONTH=MONTH           (BETWEEN 1 AND 12) 
C           IYEAR =YEAR SINCE 1900 (NEGATIVE BEFORE 1900) 
C 
      iyr1=0
      iyr=iyear/4
      if(iyear) 3,21,7
    3 iyr1=iyear/100
      if(iyear.ne.iyr1*100) goto 7 
      if(imonth.gt.2) iyr1=iyr1+1 
    7 if(iyear.ne.iyr*4) goto 21 
      if(iyr) 11,21,15
   11 if(imonth.le.2) goto 21
      iyr=iyr+1
      goto 21
   15 if(imonth.gt.2) goto 21 
      iyr=iyr-1
   21 julda =(-24980 +365*iyear)+(montot(imonth)+iday+iyr-iyr1) 

      return
      end 
