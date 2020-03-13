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
      double precision function sider2(it,DUT)
C
C CALCULATE APPARENT GREENWICH SIDERAL TIME
C
      double precision TJDH,TJDL,GST
      real dut
      integer it(6)
      include '../include/dpi.i'
C
      TJDH=julda(1,it(5),it(6)-1900) + 2440000.0D0-1.d0
      TJDL=(IT(1)*1d-2+it(2)+it(3)*6d1+it(4)*36d2+DUT)/86400d0+0.5d0
      IF(TJDL.GE.1.0d0) then
         TJDH=TJDH+1.d0
         TJDL=TJDL-1.0d0
      endif
      CALL SIDTIM (TJDH,TJDL,1,GST)
      SIDER2=GST*dpi/12.0d0
      return
      end
