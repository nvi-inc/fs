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
	SUBROUTINE CMSHF(IY,IYR,IDOYR,INDOYR,IMODP,ISSHFT,IMSHFT,
     .                 IHSHFT,IDSHFT)      !COMPUTE SIDEREAL SHIFT
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C CMSHF computes the appropriate sidereal shift in days,hours,
C minutes and seconds (to the nearest IMODP seconds).
C CALLING PROGRAM: SHFTR
C 931123 NRV Modified JULDA call to subtract 1900 from year
C
      double precision DSHFT,DSSHFT,DMSHFT,DHSHFT
C
      MJDT = JULDA(1,INDOYR,IY-1900)
      MJDS = JULDA(1,IDOYR,IYR-1900)
C
	IDELT = MJDT - MJDS
      IDSHFT = IDELT
C ADJUST BY 364/365 TO ACCOUNT FOR SHIFT
C     DSHFT = -IDELT*.002737909D0
      DSHFT = -IDELT*.002730408D0
C
      DSSHFT = DSHFT*86400.
      DMSHFT = DSSHFT/60.
      DHSHFT = DMSHFT/60.
      IDSHFT = IDSHFT+IDINT(DHSHFT)/24
C
      ISSHFT = DMOD(DSSHFT,60.D0)
      INC = IMODP/2
	IF(IDELT.GT.0) INC = -INC
      ISSHFT = ((ISSHFT+INC)/IMODP)*IMODP
C
      IMSHFT = DMOD(DMSHFT,60.D0)
      IMSHFT = IMSHFT + ISSHFT/60
      ISSHFT = MOD(ISSHFT,60)
      IHSHFT = DMOD(DHSHFT,24.D0)
C
      RETURN
      END
