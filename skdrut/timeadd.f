*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      SUBROUTINE TimeAdd(iTimeStart,idur,iTimeEnd)
! passed
        integer itimeStart(5),itimeEnd(5)
        integer idur
! local
C
C     TMADD adds a time, in seconds, to the input and returns the sum
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
C     iTimeEnd(1) - Year of stop time
C     IDAYR2 - day of stop
C     IHR2, MIN2, ISC2 - stop time
C
	logical LEAP
C
C  MODIFICATIONS
C  880411 NRV DE-COMPC'D
C 990326 nrv Let IDAY0 compute whether it's a leap year.
C
C
C     1. Simply add the duration to the seconds.  If adjustments
C     in the minutes, hours or days need to be done, do so.
C
      do i=1,5
        ItimeEnd(i)=iTimeStart(i)
      end do

      iTimeEnd(5)=ItimeEnd(5)+idur
C
      DO WHILE (iTimeEnd(5).GE.60)
          iTimeEnd(5) = iTimeEnd(5) - 60
          iTimeEnd(4) = iTimeEnd(4) + 1
      END DO
C
      DO WHILE (iTimeEnd(4).GE.60)
          iTimeEnd(4) = iTimeEnd(4) - 60
          iTimeEnd(3) = iTimeEnd(3) + 1
      END DO
C
      DO WHILE (iTimeEnd(3).GE.24)
          iTimeEnd(3) = iTimeEnd(3) - 24
          iTimeEnd(2) = iTimeEnd(2) + 1
      END DO
C
C     LEAP = MOD(iTimeEnd(1),4).EQ.0.AND. MOD(iTimeEnd(1),400).NE.0
      leap = iday0(iTimeEnd(1),0).eq.366
      DO WHILE ((iTimeEnd(2).GT.366).OR.(iTimeEnd(2).GT.365)
     >                                          .AND.(.NOT. LEAP))
          iTimeEnd(2) = iTimeEnd(2) - 365
          IF(LEAP)  iTimeEnd(2) = iTimeEnd(2) - 1
          iTimeEnd(1) = iTimeEnd(1) + 1
          LEAP = MOD(iTimeEnd(1),4).EQ.0.AND.MOD(iTimeEnd(1),400).NE.0
      END DO
C
990   RETURN
      END
