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
      REAL FUNCTION TRUN(IFEET,spd,ISPM,ISPS)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     TRUN computes the time required to run the tape at record speed
C     IFEET is the number of feet to move
C     TRUN returns the number of seconds
C
      include '../skdrincl/skparm.ftni'
C
      real spd
      integer ifeet,ispm,isps
          TRUN = (FLOAT(IFEET))/spd
      IF (IFEET.LE.0) TSPIN=0
              ISPM = IFIX(TRUN/60.0)
              ISPS = IFIX(TRUN-ISPM*60)
C
      RETURN
      END
