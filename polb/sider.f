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
      double precision function sider(it)
C
C CALCULATE APPARENT GREENWICH SIDERAL TIME
C
C ACCURATE TO APPROXIMATELY .1 SECONDS OF TIME
C
C WEH
C
      double precision eqofeq,fract,ut
      integer it(6)
      include '../include/dpi.i'
C
      ut =dble(float(it(1)))*.01d0 + dble(float(it(2)))
     +   +dble(float(it(3)))*60.d0 + dble(float(it(4)))*3600.d0
      iy=it(6)-1900
      mjd=julda(1,it(5),iy)
      call sidtm(mjd,sider,fract)
      call equn(iy,it(5),eqofeq)
      sider=sider+fract*ut+eqofeq
      sider=dmod(sider,DTWOPI)
      if (sider.lt.0.0d0) sider=sider+DTWOPI

      return
      end
