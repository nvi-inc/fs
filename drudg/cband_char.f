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
      character*1 function cband_char(vcband)
! return the bandwidth code.
! passed
      implicit none
      real vcband    !video bandwidth
! 2012Sep13.  Added BWs of 128, 65, 32
      real bandw(11)
      character*1 cband(11)
      integer i
! Return a character
      DATA BANDW/128.0,64.0,32.0,16.0,8.0,4.0,2.0,1.0,0.5,0.25,0.125/
      data cband/'G','F','E','D','8','4', '2','1','H','Q', 'E'/

      do i=1,8
       if(abs(bandw(i)-vcband) .le. 0.01) then
         cband_char=cband(i)
         return
       endif
      end do
      write(*,*) "ERROR: cband_char: Invalid band!"
      cband_char="?"
      return
      end

