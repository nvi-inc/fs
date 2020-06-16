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
      SUBROUTINE GDATE (JD, YEAR,MONTH,DAY)
! Source:
      implicit none  !2020Jun15 JMGipson automatically inserted.
! aa.usno.navy.mil/faq/docs/JD_formula.php
! Copied by JMGipson on 2019.06.06
!
!---COMPUTES THE GREGORIAN CALENDAR DATE (YEAR,MONTH,DAY)
!   GIVEN THE JULIAN DATE (JD).
!
      INTEGER JD,YEAR,MONTH,DAY,I,J,K
      integer L,N
!
      L= JD+68569
      N= 4*L/146097
      L= L-(146097*N+3)/4
      I= 4000*(L+1)/1461001
      L= L-1461*I/4+31
      J= 80*L/2447
      K= L-2447*J/80
      L= J/11
      J= J+2-12*L
      I= 100*(N-49)+I+L

      YEAR= I
      MONTH= J
      DAY= K

      RETURN
      END
