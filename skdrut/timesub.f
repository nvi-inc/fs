	SUBROUTINE TimeSub(iTimeStart,idur,iTimeEnd)
! passed
        integer itimeStart(5),itimeEnd(5)
        integer idur
! local
        integer i
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
	logical LEAP
C
C  MODIFICATIONS
C  880411 NRV DE-COMPC'D

C
C     1. Simply subtract the duration from the minutes.  If adjustments
C     in the minutes, hours or days need to be done, do so.
C
      do i=1,5
        ItimeEnd(i)=iTimeStart(i)
      end do
      iTimeEnd(5)=ItimeEnd(5)-idur

C
      DO WHILE (itimeEnd(5).LT.0)
          itimeEnd(5) = itimeEnd(5) + 60
          itimeEnd(4) = itimeEnd(4) - 1
      END DO
C
      DO WHILE (itimeEnd(4).LT.0)
          itimeEnd(4) = itimeEnd(4) + 60
          itimeEnd(3) = itimeEnd(3) - 1
      END DO
C
      DO WHILE (itimeEnd(3).LT.0)
          itimeEnd(3) = itimeEnd(3) + 24
          itimeEnd(2) = itimeEnd(2) - 1
      END DO
C
      DO WHILE (itimeEnd(2).LT.1)
          itimeEnd(2) = itimeEnd(2)+365
          itimeEnd(1) =itimeEnd(1) - 1
          leap = IDAY0(itimeEnd(1),0).eq. 366
          IF (LEAP)  itimeEnd(2) =itimeEnd(2) + 1
      END DO
C
990   RETURN
      END
