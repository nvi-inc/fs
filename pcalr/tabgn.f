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
      subroutine tabgn(itabl)
      implicit none
      integer itabl(256)
c
c  TABLE GENERATOR FOR SOFTWARE CORRELATOR  ARW 780916
c  COMPUTE TABLE OF # OF 1's IN EACH OF OCTAL NUMBERS 0-255 AND MAKE TABLE
c  converted to fortran weh 920119
c
      integer i,j,ib
      logical bjtest
c
      do i=0,255
        ib=0
        do j=0,7
          if(bjtest(i,j)) ib=ib+1
        enddo
        itabl(i+1)=ib
      enddo
c
      return
      end
