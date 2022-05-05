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
      subroutine proc_check8bbc(km3be,km3ac,lwhich8,ichan,
     >  ib,kinclude)
      implicit none
! Check to see if we should do this BBC.
! This is only called in the case we have 8 BBCs.
! History
!  2007Jul12 JMGipson. Split off from proc.

! passed
      logical km3be     !Mark3 mode B or E
      logical km3ac     !Mark3 mode A or C
      character*1 lwhich8      !flag indicating (F)irst or (L)ast 8 BBCs
      integer ichan     !which channel
! returned
      integer ib
      logical kinclude  !

      kinclude=.true. 
      ib=ichan          !default
      if (km3be) then
!        ib=ichan
      else if (km3ac) then
        if (lwhich8 .eq. "F") then
!          ib=ichan
          if (ib.gt.8) kinclude=.false.
C           Write out a max of 8 channels for 8-BBC stations
        else if (lwhich8 .eq. "L") then
           ib=ichan-6
           if (ib.le.0) kinclude=.false.
        endif
      endif
      return
      end
