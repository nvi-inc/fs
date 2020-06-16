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
      subroutine proc_tapef_name(code,cpmode,cnamep)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'
! passed
      character*2 code
      character*4 cpmode
! returned
      character*12 cnamep
! function
      integer trimlen
! local
      integer nch1
      integer nch2

      nch1=trimlen(code)
      nch2=trimlen(cpmode)
      cnamep="tapef"//code(1:nch1)//cpmode(1:nch2)
      nch1=nch1+nch2+6
      if (krec_append) cnamep(nch1:nch1)=crec(irec)
      return
      end

