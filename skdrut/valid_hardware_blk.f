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
      subroutine valid_hardware_blk()
      implicit none  !2020Jun15 JMGipson automatically inserted.
!      block data
! Used to initialize by block data, but doesn't work for some linux systems.
!
      include "../skdrincl/valid_hardware.ftni"
      integer i
! Valid Rack types
      crack_type(1)=     'none'
      crack_type(2)=     'Mark3A'
      crack_type(3)=     'VLBA'
      crack_type(4)=     'VLBAG'
      crack_type(5)=     'VLBA/8'
      crack_type(6)=     'VLBA4/8'
      crack_type(7)=     'Mark4'
      crack_type(8)=     'VLBA4'
      crack_type(9)=     'K4-1'
      crack_type(10)=    'K4-2'
      crack_type(11)=    'K4-1/K3'
      crack_type(12)=    'K4-2/K3'
      crack_type(13)=    'K4-1/M4'
      crack_type(14)=    'K4-2/M4'
      crack_type(15)=    'LBA'
      crack_type(16)=    'Mark5'
      crack_type(17)=    'VLBA5'
      crack_type(18)=    'DBBC_DDC'
      crack_type(19)=    'DBBC_DDC/Fila10g'
      crack_type(20)=    'DBBC_DDC/VSI2'
      crack_type(21)=    'DBBC_PFB'
      crack_type(22)=    'DBBC_PFB/Fila10g'
      crack_type(23)=    'RDBE'
      crack_type(24)=    'VLBAC'
      crack_type(25)=    'CDAS'
      crack_type(26)=    'BB'
      crack_type(27)=    'unknown'

! Valid recorder types
      crec_type(1)=     'none'
      crec_type(2)=     'unused'
      crec_type(3)=     'Mark3A'
      crec_type(4)=     'VLBA'
      crec_type(5)=     'VLBA4'
      crec_type(6)=     'Mark4'
      crec_type(7)=     'S2'
      crec_type(8)=     'K4-1'
      crec_type(9)=     'K4-2'
      crec_type(10)=    'Mark5A'
      crec_type(11)=    'Mk5APigW'
      crec_type(12)=    'Mark5P'
      crec_type(13)=    'K5'
      crec_type(14)=    'Mark5B'
      crec_Type(15)=    'Mark5C'
      crec_type(16)=    'FlexBuff'
      crec_type(17)=    'Mark6'
      crec_type(18)=    'unknown'

! Make version of the above in capitalform.
      do i=1,max_rack_type
        crack_type_cap(i)=crack_type(i)
        call capitalize(crack_type_cap(i))
      end do

      do i=1,max_rec_type
        crec_type_cap(i)=crec_type(i)
        call capitalize(crec_type_cap(i))
      end do
      return
      end
