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
      LOGICAL FUNCTION KNAEQ(L1,L2,ILEN)
C
C     Returns TRUE if all words of names L1 and L2 are equal.  This is
C     a test of equality of string names.
C
      include '../skdrincl/skparm.ftni'
C
      integer*2 L1(*),L2(*)
      integer ilen,i
C
      I=1
      DO WHILE ((I.LE.ILEN).AND.(L1(I).EQ.L2(I)))
        I=I+1
      END DO
C                   Increment counter while words are equal
      IF  (I.EQ.ILEN+1)  THEN
        KNAEQ=.TRUE.
      ELSE
        KNAEQ=.FALSE.
      ENDIF
      RETURN
      END
