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
      subroutine name_trkf(lmode,lpmode,lpass,lnamep)
      include 'hardware.ftni'
! passed.
      character*(*) lmode
      character*(*) lpmode
      character*1 lpass
! returned
      character*(*) lnamep
      integer ilast_non_blank

! 2015Jun05. Removed commented out code. 

      if(knopass) then
        write(lnamep,'("trkf",a)') lmode
      else
        write(lnamep,'("trkf",a,a,a1)') lmode,lpmode,lpass
      endif
      call squeezeleft(lnamep,ilast_non_blank)
      end

