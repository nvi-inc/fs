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
      logical function ktimedif(itime1,itime2)
! Return true if the times are different.
      implicit none  !2020Jun15 JMGipson automatically inserted.
      integer itime1(5),itime2(5)          !iyear,iday,ihour,imin,isec

      ktimedif= (itime1(1) .ne. itime2(1)) .or.
     >          (itime1(2) .ne. itime2(2)) .or.
     >          (itime1(3) .ne. itime2(3)) .or.
     >          (itime1(4) .ne. itime2(4)) .or.
     >          (itime1(5) .ne. itime2(5))
      return
      end
