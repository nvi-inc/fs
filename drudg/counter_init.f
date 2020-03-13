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
      real function counter_init(km5,k4,ks2,iTapeLength)
      logical k4
      logical ks2
      logical km5
      integer iTapeLength
      if(k4) then
       counter_init=54
      else if(ks2) then
       counter_init=0
      else if(km5) then
       counter_init=0
      else
       if(ItapeLength .gt. 10000) then   !Thintape check
         counter_init=200
        else
         counter_init=100
        endif
! the following is here to test for compatibility. Remove in final.
!      counter_init=0
      endif
      return
      end
