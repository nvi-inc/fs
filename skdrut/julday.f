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
       function julday(iyear,imonth,iday)
      implicit none
! Return the Julian day given the year,month date in the Gregorian Calendar currently in use.
       integer(int32) julday
       integer iyear, imonth, iday   !Year, month, day .   January = 1, ...Dec=12. Year is 4 digit.

       integer itmp
! 2019.05.16.  John Gipson
!
! written by JMGipson using algorithm from Wikipedia:
!
!  JDN = (1461 × (Y + 4800 + (M − 14)/12))/4 +
!       (367 × (M − 2 − 12 × ((M − 14)/12)))/12 − (3 × ((Y + 4900 + (M - 14)/12)/100))/4 + D − 32075
!

! Some simple checks on validity of input.
       if(imonth .lt. 0 .or. imonth .gt. 12) then
         write(*,*) "ERROR!  julday: Month must be between 1 and 12"
         write(*,*) "           was: ", imonth
         goto 500
       elseif(iday .lt. 0 .or. iday .gt. 31) then
         write(*,*) "ERROR!  julday: Day must be between 1 and 31"
         write(*,*) "           was: ", iday
         goto 500
       endif

       julday=(1461*(iyear + 4800 + (imonth - 14)/12))/4 + (367 * (imonth - 2 - 12 * ((imonth - 14)/12)))/12 &
    &   - (3 * ((iyear + 4900 + (imonth - 14)/12)/100))/4 + iday - 32075
       return

! This causes a hard error that should case the program to crash.
! If compiled with traceback and debugging then we can find offending routine.
! (gfortran -fbacktrace;  ifort -traceback)
! offending routine.
500    continue
       itmp=0
       write(*,*) 1/itmp
       return

       end
! Tested against NR using  several randomly selected dates. "NEW is this routine"
!
!Enter in year, month, date: 2018 4 3
! NR:       2458212
! NEW:      2458212
!Enter in year, month, date: 1950 12 3
! NR:       2433619
! NEW:      2433619
!Enter in year, month, date: 1830 2 7
! NR:       2389491
! NEW:      2389491
!Enter in year, month, date: 2013 1 1
! NR:       2456294
! NEW:      2456294
!Enter in year, month, date: 3000 2 5
! NR:       2816823
! NEW:      2816823

