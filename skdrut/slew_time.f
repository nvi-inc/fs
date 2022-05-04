*
* Copyright (c) 2021 NVI, Inc.
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
!*************************************************************************************************      
      real function slew_time(x1,x2,off,vel,acc)   
      implicit none    
! Passed      
      real x1,x2   !starting stopping point
      real off     !settling time
      real vel     !velocity          
      real acc     !acceleration
! 2021-12-15 JMGipson.   Added forgotten 2.0 before sqrt.

! local
      real dist 
      real t_acc   !time to accelerate to terminal velocity

      
      dist=abs(x1-x2)
      t_acc=vel/acc
      
      if(dist  .le.  acc*t_acc*t_acc) then
         slew_time=2.0d0*sqrt(dist/acc)
      else
         slew_time=dist/vel+t_acc
      endif
      slew_time=slew_time+off 
      return
      end 
