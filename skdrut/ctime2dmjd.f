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
      double precision Function ctime2dmjd(ctim_skd)
! convert a sked character*11 string into double precision time.
! passed
      implicit none
      character*11 ctim_skd
! function
      integer julda
      double precision hms2seconds
! local
      integer iy_skd,idoy_skd,ih_skd,im_skd,is_skd

      read(ctim_skd,'(i2,i3,3i2)') iy_skd,idoy_skd,ih_skd,im_skd,is_skd
      if(iy_skd.gt.50) then
        iy_skd=iy_skd+1900
      else
        iy_skd=iy_skd+2000
      endif
!      write(*,*) iy_skd,idoy_skd,ih_skd,im_skd,is_skd
!      write(*,*) hms2seconds(ih_skd,im_skd,is_skd)

      CTime2dmjd=dble(JULDA(1,idoy_skd,iy_skd-1900))+
     >     hms2seconds(ih_skd,im_skd,is_skd)/86400.d0
!      write(*,*) Ctime2dmjd
      return
      end
