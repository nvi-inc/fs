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
C!VWMOV
      subroutine vwmov(v1,incr1,v2,incr2,num)
      implicit none
      real*4 v1(1),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V2
C
C  MOVE LOCAL MEMORY TO EMA
C
      integer*2 i,index1
      integer*4 jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.0.and.incr2.eq.1) then
         do i=1,num
           v2(i)=v1(1)
         enddo
      else
        index1=1
        jndex2=1j
        do i=1,num
          v2(jndex2) = v1(index1)
          index1=index1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
