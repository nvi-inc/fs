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
      integer function iday_of_year(iyear,imonth,iday)
      implicit none
! Return the day of year.
      integer iyear,imonth,iday
! 2019May15 JMGipson. First version
! 2019Sep04 JMGipson. Second version.  Take into account that we only add leapday after February

! local

      integer imon_offset(12)
      integer ileap_day
      data imon_offset/0,31,59,90,120,151,181,212,243,273,304,334/

      if(mod(iyear,400) .eq. 0) then
         ileap_day=1
      else if(mod(iyear,100) .eq.0) then
         ileap_day=0
      else if(mod(iyear,4) .eq. 0) then
         ileap_day=1
      else
         ileap_day=0
      endif

      iday_of_year=imon_offset(imonth)+iday
      if(imonth .gt. 2) then
        iday_of_year=iday_of_year+ileap_day
      endif

      return
      end 
