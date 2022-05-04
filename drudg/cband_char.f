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
! Update
! 2020-12-31 JMG  Rewritten to make it easier to understand and expand 
! 2020-01-11 JMG  Made all the charaters lower case 
      character*12 cband
      integer i    !counter
      real       bw_test 
!
      data cband/"abc1248defgh"/
! Return a character     
! Start at BW=0.125MHz and double.
! .125 MHz=a
! .250 MHz=b
! .500 MHz=c
! 1.0  MHz=1
! 2.0  MHz=2
! 4.0  MHz=4
! 8.0  MHz=8
!16.0  MHz=d
!32    MHz=e
! 64       f
!128       g
!256       h
! etc
      bw_test=0.125      !BW in MHz
      do  i=1,12
        if(abs(bw_test-vcband) .le. 0.01) then
         cband_char=cband(i:i)
         return
        endif
        bw_test=2*bw_test 
      end do
      write(*,*) "ERROR: cband_char: Invalid band!"
      write(*,'("Last BW tested was: ",f8.2)')  bw_test/2 
      cband_char="?"
      return
      end

