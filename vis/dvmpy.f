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
C!DVMPY
      subroutine dvmpy(v1,incr1,v2,incr2,v3,incr3,num)
      implicit none
      double precision v1(1),v2(1),v3(1)
      integer incr1,incr2,incr3,num
C
C  DOUBLE PRECISION: MULTIPLY
C
      integer*2 i,index1,index2,index3
C
      if(incr1.eq.1.and.incr2.eq.1.and.incr3.eq.1) then
        do i=1,num
          v3(i) = v1(i) * v2(i)
        enddo
      else
        index1=1
        index2=1
        index3=1
        do i=1,num
          v3(index3) = v1(index1) * v2(index2)
          index1=index1+incr1
          index2=index2+incr2
          index3=index3+incr3
        end do
      endif
C
      return
      end
