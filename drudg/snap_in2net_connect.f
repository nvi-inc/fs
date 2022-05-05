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
      subroutine snap_in2net_connect(lu,ldestin,loptions)
      implicit none
! passed
      integer lu
      character*(*) ldestin     !destionation
      character*(*) loptions    !options
! funcionts
      integer trimlen
! 2015Jun05 JMG. Repalced squeezewrite by drudg_write. 

! local
      integer nch2,nch3
      character*200 ldum
      if(ldestin .eq. " ") return

      nch2=trimlen(ldestin)
      if(nch2 .eq. 0) nch2=1
      nch3=trimlen(loptions)
      if(nch3.eq. 0) nch3=1
      write(ldum,"('in2net=connect,',a,',',a)")
     >  ldestin(1:nch2),loptions(1:nch3)
      call drudg_write(lu,ldum)       !get rid of spaces, and write it out.
      return
      end
