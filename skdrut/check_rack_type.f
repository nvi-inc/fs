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
      subroutine check_rack_type(crack)
      include '../skdrincl/valid_hardware.ftni'

! Passed.
      character*(*) crack     !rack

! Check for crack being a valid rack type. If not set to "unknown".
! This does two checks:
!  1. Normal. If it finds, returns w/o doing anythying.
!  2. Capitalized. If it finds capitalized version of crack, then returns
!     normal version.
! History
!  2006Nov30 JMGIpson. First version.

! functions
      integer iwhere_in_string_list
! local
      integer iwhere
      character*8 cracktmp
      write(*,*) crack_type
      write(*,*) "In: ", crack 

      iwhere=iwhere_in_string_list(crack_type, max_rack_type,crack)
      if(iwhere .ne. 0) return           !valid rack type.

! Didn't find. Capitalize and try again.
      cracktmp=crack
      call capitalize(cracktmp)
      iwhere=
     >   iwhere_in_string_list(crack_type_cap,max_rack_type,cracktmp)
      if(iwhere .eq. 0) then
        write(*,*) "Check_rack_type: Invalid rack ",crack,
     >     " setting to unknown!"
        crack="unknown"
      else
        crack=crack_type(iwhere)
      endif
      return
      end
