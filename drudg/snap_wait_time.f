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
      subroutine snap_wait_time(luFile,itimevec)
! write out wait command
      implicit none
! passed
      integer itimevec(5)
      integer luFile
! local
      integer i

      integer itime_save(5)
      common /time_save/itime_save

      do i=1,5
        itime_save(i)=itimevec(I)
      end do


      write(luFile,'("!",i4.4,".",i3.3,".",2(i2.2,":"),i2.2)')
     >  itimeVec(1:5)
      return
      end
!************************************************************
      subroutine snap_get_last_wait_time(itimeout)
      implicit none
      integer itimeout(5)
      integer i
! return last wait time.
      integer itime_save(5)
      common /time_save/itime_save

      do i=1,5
         itimeout(i)=itime_save(i)
      end do
      return
      end



