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
      integer function iwhere_in_range4(range_vec, num_range, temp)
! Find location of value within some range. 
      implicit none 

! On entry
      real*4  range_vec(num_range)      !vector of non-decreasing values.
      integer num_range    
      real*4  temp                      !value we are searching for.
     
! On exit
!     iwhere_in_range4        =0.  Not in range. 
!                             <>0:     range_vec(iwhere_in_range) <= temp <= range_vec(iwhere_in_range+1)     

!  range      numbers in non-decreasing order
!  num_range  dimension 
!  value      value we are looking for.
 
! Check to see if in range.
       if(temp.lt.range_vec(1) .or. temp.gt.range_vec(num_range)) then
         iwhere_in_range4=0     !return with error
         return
       endif 

! now check where we are.
      do iwhere_in_range4 =1, num_range-1
         if(range_vec(iwhere_in_range4) .le. temp .and. 
     &      range_vec(iwhere_in_range4+1) .ge. temp) return 
      end do
      iwhere_in_range4=0
      return
      end 
    
