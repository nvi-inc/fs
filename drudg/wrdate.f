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
      Subroutine wrdate(lu,iyr,idayr)
C  Write a line in the VLBA output file with the new date.
C  NRV 910705
C 980910 nrv Write out the full 4-digit year.
! 2006Sep28 rewritten to use ascii.
! 2014Feb05 JMG Made iyr, idayr integer*2
      implicit none  !2020Jun15 JMGipson automatically inserted.

C Input:
      integer lu
      integer*2 iyr,idayr
C  lu - output unit
C  iyr - year, e.g. 1991, i.e. 4-digits
C  idayr - day of year, e.g. 201
C
C Local:
      integer*2 lmon(2),lday(2)
      character*3 cmon
      equivalence (lmon,cmon)

      integer imon,ida
      imon = 0
      ida = idayr
      call clndr(iyr,imon,ida,lmon,lday)
      write(lu,'("date = ",i4,a,i2.2)') iyr,cmon,ida
      write(*,'("date = ",i4,a,i2.2)') iyr,cmon,ida
      return
      end
