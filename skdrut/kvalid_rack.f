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
      logical function kvalid_rack(crack)
      implicit none
      include '../skdrincl/valid_hardware.ftni'

! Passed.
      character*(*) crack     !rack

! Check for crack being a valid rack type. If not kvalid=.false.
! This does two checks:
!  1. Normal. If it finds, returns w/o doing anythying and kvalid=.true.
!  2. Capitalized. If it finds capitalized version of crack, then returns
!     normal version.
! History
!  2006Nov30 JMGIpson. First version.
!  2013Sep25 JMGipson. Modeled on check_rack_type. But bug fixed and made funciton. 
!  2015Mar30 JMG. Fixed a bug.  

! functions
      integer iwhere_in_string_list
! local
      integer i
      character*8 cracktmp
 

      kvalid_rack=.true.
      i=iwhere_in_string_list(crack_type, max_rack_type,crack)
    
      if(i .ne. 0) return           !valid rack type.
   
! Didn't find. Capitalize and try again.
      cracktmp=crack
      call capitalize(cracktmp)
      i=iwhere_in_string_list(crack_type_cap,max_rack_type,cracktmp)
      if(i .ne. 0) then
         crack=crack_type(i)             
      else
         kvalid_rack=.false.
      endif
      return
      end
