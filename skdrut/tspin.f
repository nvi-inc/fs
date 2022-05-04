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
      REAL FUNCTION TSPIN(IFEET,ISPM,SPS,iTapeSpinDelay)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     TSPIN computes the time required to spin the tape at 270 ips=22.5 fps
C     IFEET is the number of feet to move
C     TSPIN returns the number of seconds
C 021014 nrv Change seconds argument to real.
! 2003Nov12  JMGipson changed calculation. Added iSpinDelay
C
      include '../skdrincl/skparm.ftni'
C
      integer ifeet,ispm
      integer iTapeSpinDelay  !time to startup
      real sps
! Changed this logic.
!      TSPIN = (FLOAT(IFEET)-160.0)/22.5 + 10.0
      Tspin=float(ifeet)/22.5+iTapeSpinDelay
      IF (IFEET.LE.0) TSPIN=0
      ISPM = IFIX(TSPIN/60.0)
      SPS = TSPIN-ISPM*60.0
C
      RETURN
      END
