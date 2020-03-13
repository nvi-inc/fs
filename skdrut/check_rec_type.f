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
      subroutine check_rec_type(crec)
      include '../skdrincl/valid_hardware.ftni'

! Passed.
      character*(*) crec     !rec
! Check for crec being a valid rec type. If not set to "unknown".
! This does two checks:
!  1. Normal. If it finds, returns w/o doing anythying.
!  2. Capitalized. If it finds capitalized version of crec, then returns
!     normal version.
! History
!  2006Nov30 JMGIpson. First version.

! functions
      integer iwhere_in_string_list
! local
      integer iwhere
      character*8 crectmp

      iwhere=iwhere_in_string_list(crec_type, max_rec_type,crec)
!      if(iwhere .eq. 0) return           !valid rec type.

! Didn't find. Capitalize and try again.
      crectmp=crec
      call capitalize(crectmp)
      iwhere= iwhere_in_string_list(crec_type_cap,max_rec_type,crectmp)
      if(iwhere .eq. 0) then
!        write(*,*) "Check_rec_type: Invalid recorder ",crec,
!     >     " setting to unknown!"
        crec="unknown"
      else
        crec=crec_type(iwhere)
      endif
      return
      end
