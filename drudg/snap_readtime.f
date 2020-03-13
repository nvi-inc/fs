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
      subroutine snap_ReadTime(lbuf,itime_vec,kvalid)
      implicit none
! Read in the time.
! on entry
      character*40 lbuf
! on exit
      integer itime_vec(5)      !time vector
      logical kvalid            !got a valid time?
! local
      character*40 lformat
      integer iyear,iday,ihour,imin,isec

! initialize
      kvalid=.true.

      if (index(lbuf,'.').ne.0) then ! punctuation
        lformat='(i4,1x,i3,3(1x,i2))'
        read(lbuf(2:40),lformat,err=100) iyear,iday,ihour,imin,isec
        itime_vec(1)=iyear
      else ! numbers only
        lformat='(i3,3i2)'
        read(lbuf(2:40),lformat,err=100) iday,ihour,imin,isec
      endif ! punctuation/numbers
      itime_vec(2)=iday
      itime_vec(3)=ihour
      itime_vec(4)=imin
      itime_vec(5)=isec
      return

100   continue
      kvalid=.false.
      return
      end
