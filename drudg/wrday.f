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
      Subroutine wrday(lu,iyr,idayr)
C  Write a line in the SNAP summary with the new date.
C History
C 990305 nrv New. Copied from wrdate.
!     2006Sep28 Rewrriten to remove hollerith

C Input:
      integer lu,iyr,idayr
C  lu - output unit
C  iyr - year, e.g. 1991, i.e. 4-digits
C  idayr - day of year, e.g. 201
C
C Local:
      integer*2 lmon(2),lday(2)
      character*3 cmon
      equivalence (lmon,cmon)

      imon = 0
      ida = idayr
      call clndr(iyr,imon,ida,lmon,lday)
      write(lu,'("date = ",i4,a3,i2,"  DOY = ",i3)')
     > iyr,cmon,ida,idayr

      return
      end
