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
      integer function iTimeDifSec(itime1,itime2)
! on entry
      implicit none
      integer itime1(5),itime2(5)       !iyr,idoy,ihr,imin,isec
!
      double precision DelTime

      DelTime=itime1(5)-itime2(5)+60.*(itime1(4)-itime2(4))
     >  +3600.*(itime1(3)-itime2(3))
! this may happen at year end.
      if(itime1(1)-itime2(1) .eq. 1) then
         DelTime=DelTime+86400.d0
      else
         DelTime=DelTime+86400.d0*(itime1(2)-itime2(2))
      endif
      iTimeDifSec=DelTime

      return
      end
