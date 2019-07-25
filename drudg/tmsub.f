	SUBROUTINE TMSUB(IYR,IDAYR,IHR,MIN,ISC,IDUR,IYR2,IDAYR2,IHR2,MIN2,
     .           ISC2)!,SUBTRACT TWO TIMES C#870115:16:10#
C
C     TMSUB subtracts a time, in seconds, from the input
C     and returns the difference
C
C  INPUT:
C
C     IYR - Year of start time
C     IDAYR - day of the year for start time
C     IHR, MIN, ISC - start time
C     DUR - duration, seconds
C
C
C  OUTPUT:
C
C     IYR2 - Year of stop time
C     IDAYR2 - day of stop
C     IHR2, MIN2, ISC2 - stop time
C
	logical*4 LEAP
C
C  MODIFICATIONS
C  880411 NRV DE-COMPC'D
C
C
C     1. Simply subtract the duration from the minutes.  If adjustments
C     in the minutes, hours or days need to be done, do so.
C
      IYR2 = IYR
      IDAYR2 = IDAYR
      IHR2 = IHR
      MIN2 = MIN
      ISC2 = ISC - IDUR
C
      DO WHILE (ISC2.LT.0)
          ISC2 = ISC2 + 60
          MIN2 = MIN2 - 1
      END DO
C
      DO WHILE (MIN2.LT.0)
          MIN2 = MIN2 + 60
          IHR2 = IHR2 - 1
      END DO
C
      DO WHILE (IHR2.LT.0)
          IHR2 = IHR2 + 24
          IDAYR2 = IDAYR2 - 1
      END DO
C
      DO WHILE (IDAYR2.LT.1)
          IDAYR2 = IDAYR2+365
          IYR2 =IYR2 - 1
          LEAP = MOD(IYR2,4).EQ.0.AND.MOD(IYR2,400).NE.0
          IF (LEAP)  IDAYR2 =IDAYR2 + 1
      END DO
C
990   RETURN
      END
