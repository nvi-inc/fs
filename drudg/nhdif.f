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
	integer function nhdif(idnow,ihnow,imnow,id1,ih1,im1)

C  NHSK computes the number of hours between day/hour/min now (end)
C       and day/hour/min 1 (start).
C       Assumes time "now" is later than time "1".
C NRV 910911 Removed rounding to next higher hour

	nd = idnow - id1
	nh = ihnow - ih1
	nm = imnow - im1
	if (nm.lt.0) then
	  nm = nm + 60
	  nh = nh - 1
	endif
	if (nh.lt.0) then
	  nh = nh + 24
	  nd = nd - 1
	endif
C       nhdif = nd*24 + nh + (nm+30)/60
        nhdif = nd*24 + nh

	return
	end
