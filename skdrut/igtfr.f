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
      integer FUNCTION IGTFR(LKEYWD,IKEY)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
C     CHECK THROUGH LIST OF CODES FOR A MATCH WITH LKEYWD
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
      integer*2 lkeywd(*)
      integer ikey,i
      IKEY=0
      IGTFR = 0
      IF (NCODES.LE.0) RETURN
      DO 100 I=1,NCODES
        IF (LCODE(I).EQ.LKEYWD(1)) GOTO 110
100   CONTINUE
      RETURN
110   IKEY=I
      IGTFR = I
      RETURN
      END
