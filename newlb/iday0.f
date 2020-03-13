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
C@IDAY0
      INTEGER FUNCTION IDAY0 ( IYEAR , MONTH )
C     Get # elapsed days in year to date  TAC 760102 
C 
C     THIRTY DAYS HATH SEPTEMBER, APRIL, JUNE AND NO WONDER . . . . .
C 
C-----IF 1<=MONTH<=12, THIS FUNCTION RETURNS THE NUMBER OF ELAPSED DAYS 
C     ON DAY NUMBER ZERO OF A GIVEN MONTH........ 
C              I.E., IF MONTH = 2 (FEB), IDAY0 = 31 ( = JAN 31) 
C     WITH LEAP YEARS ACCOUNTED FOR PROPERLY. 
C 
C-----IF MONTH <=0 OR IF MONTH >=13, IDAY0 = NUMBER OF DAYS IN IYEAR. 
C 
C     T.A.C.                                     02 JAN 1976
C     WEH  not qute 2000 IS a leap year          02 SEP 1998
C 
C-----MAXYR = MAXIMUM DAYS IN IYEAR:
      MAXYR ( IYR )   =     366 
     *     -     ( ( MOD ( IYR        ,    4 ) + 3 ) /    4 ) 
     *     -     ( ( MOD ( IYR +   99 ,  100 ) + 1 ) /  100 ) 
     *     +     ( ( MOD ( IYR +  399 ,  400 ) + 1 ) /  400 )
C 2000 is a leap year
C    *     -     ( ( MOD ( IYR + 1999 , 2000 ) + 1 ) / 2000 ) 
C                                       WHEW! 
C 
C-----TEST MONTH: 
C 
      IF ( ( MONTH .LE. 0 ) .OR. ( MONTH .GT. 12 ) ) GO TO 12 
C 
C-----RETURN DAYS TO START OF MONTH:
C 
      IDAY0      =     31 * ( MONTH - 1 ) 
     X - INT ( 2.2 + 0.4 * FLOAT ( MONTH ) + 365 - MAXYR (IYEAR) )
     X          * ( ( MONTH + 9 ) / 12 )
      RETURN
C 
C-----RETURN MAXYR: 
C 
12    IDAY0 = MAXYR ( IYEAR ) 
      RETURN
      END 
