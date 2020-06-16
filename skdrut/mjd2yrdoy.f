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
      subroutine mjd2yrDoy(mjd,iyear,idoy)
! History
! 2019Jun10  JMG. Revised to use non-NR routines
! Pass
      implicit none  !2020Jun15 JMGipson automatically inserted.
      integer*4 mjd
! Return
      integer iyear,idoy     ! idoy=iday of year.
! functions
      integer iday_of_year
! local
      integer imon,iday
      integer*4 mjd_temp
      integer*4 jday
! convert to mon,day,year
      jday=mjd+2440000
      call gdate(jday,iyear,imon,iday)
      idoy=iday_of_year(iyear,imon,iday)
      return
      end



