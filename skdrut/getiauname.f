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
      subroutine GetIauName(ltest,rarad2k,decrad2k)
! get the iau name.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
! input
      real*8 rarad2k,decrad2k
! output
      character*8 ltest
      real*8 ra50,dec50
      real*8 md
      integer ih,im,id,ifd

C Initialized:
C 1. Precess to get the 1950 position.
      call prefr(rarad2k,decrad2k,2000,ra50,dec50)
C 2. Elements of the IAU name.
      ih = ra50*12.d0/pi
      im = ((ra50*12.d0/pi) - ih)*60.d0
      id = dec50*180.d0/pi
      md = ((dec50*180.d0/pi) - id + 0.d0001)*60.d0
      ifd = abs(md)/6.0

C 3. Convert integer to ASCII
      write(ltest,'(2i2.2,1x,i2.2,i1.1)') ih,im,iabs(id),ifd
      if(dec50 .lt. 0) then
         ltest(5:5)="-"
      else
        ltest(5:5)="+"
      endif
      return
      end







