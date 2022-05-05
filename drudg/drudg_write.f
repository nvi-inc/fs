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
      subroutine drudg_write(lufile,ldum)
! Routine that:  a.) Removes spaces; b.) converts everthing to lowercase; c.) writes out results. 
      implicit none
! passed
      integer lufile
      character*(*) ldum
! History
! 2015Jun05. JMG. Basically same as "squeezewrite" routine with addtion of 'call lowercase'
! 
! local
      integer ilast_non_blank  !last non-blank
      call lowercase(ldum) 
      call squeezeleft(ldum,ilast_non_blank)
 
      write(lufile,'(a)') ldum(1:ilast_non_blank)
      return
      end
