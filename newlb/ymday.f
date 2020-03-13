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
C@YMDAY

      SUBROUTINE YMDAY ( IYEAR, IDAYR, MONTH, IDAY )
C     Convert day-of-year to month and day TAC 760207
C 
C     IF IDAYR>0, 
C         THIS ROUTINE WILL CONVERT IDAYR = ELAPSED DAY-OF-THE-YEAR 
C         INTO MONTH AND IDAY. IF IDAYR>365 (OR >366 FOR A LEAP YEAR) 
C         THE YEAR WILL BE INCREMENTED ACCORDINGLY, AND IDAYR WILL BE 
C         'CORRECTED'.
C 
C     IF IDAYR <=0, 
C         THE MONTH AND IDAY FIELDS WILL BE CONVERTED INTO DAY-OF-THE-
C         YEAR AND RETURNED IN IDAYR. 
C 
C     THIS ROUTINE CALLS IDAY0 ( IYEAR , 0 ) TO GET NUMBER OF DAYS
C     IN IYEAR AND IDAY0 ( IYEAR , MONTH ) TO GET THE DAY NUMBER OF 
C     THE ZEROTH DAY OF THE MONTH.
C 
C          T.A.CLARK     02 JAN '76       REVISED 07 FEB '76
C 
C-----WAS THE ENTRY MONTH AND DAY OR DAY-OF-YEAR? 
C 
      IF ( IDAYR .LE. 0 ) GO TO 3 
C 
C-----FIRST, CHECK TO SEE IF IDAYR IS VALID:
1     IF ( IDAYR .LE. IDAY0 ( IYEAR , 0 ) ) GO TO 2 
      IDAYR = IDAYR - IDAY0 ( IYEAR , 0 ) 
      IYEAR = IYEAR + 1 
      GO TO 1 
C 
C-----NOW, FIND THE MAGIC MONTH:
C 
2       DO 21 M = 1 , 12
        MONTH = M 
        IF ((IDAY0(IYEAR,M+1) .GE. IDAYR) .OR. (M .GE. 12)) GO TO 22
21      CONTINUE
C 
C-----AND NOW FIND THE DAY-OF-THE-MONTH AND RETURN: 
C 
22    IDAY = IDAYR - IDAY0 ( IYEAR , MONTH )
      RETURN
C 
C-----GET DAY-OF-THE-YEAR IF MONTH AND IDAY WAS ENTERED:
C 
3     IDAYR = IDAY + IDAY0 ( IYEAR , MONTH )
C 
      RETURN
      END 

