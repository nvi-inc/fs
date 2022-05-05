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
      SUBROUTINE TMADD(IYR,IDAYR,IHR,MIN,ISC,IDUR,IYR2,IDAYR2,
     .                 IHR2,MIN2,ISC2)!,ADD DURATION TO START C#870115:16:10#
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
C     IYR2 - Year of stop time
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
      IYR2 = IYR
      IDAYR2 = IDAYR
      IHR2 = IHR
      MIN2 = MIN
      ISC2 = ISC + IDUR
C
      DO WHILE (ISC2.GE.60)
          ISC2 = ISC2 - 60
          MIN2 = MIN2 + 1
      END DO
C
      DO WHILE (MIN2.GE.60)
          MIN2 = MIN2 - 60
          IHR2 = IHR2 + 1
      END DO
C
      DO WHILE (IHR2.GE.24)
          IHR2 = IHR2 - 24
          IDAYR2 = IDAYR2 + 1
      END DO
C
C     LEAP = MOD(IYR2,4).EQ.0.AND. MOD(IYR2,400).NE.0
      leap = iday0(iyr2,0).eq.366
      DO WHILE ((IDAYR2.GT.366).OR.(IDAYR2.GT.365).AND.(.NOT. LEAP))
          IDAYR2 = IDAYR2 - 365
          IF(LEAP)  IDAYR2 = IDAYR2 - 1
          IYR2 = IYR2 + 1
          LEAP = MOD(IYR2,4).EQ.0.AND.MOD(IYR2,400).NE.0
      END DO
C
990   RETURN
      END
