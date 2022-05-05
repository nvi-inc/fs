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
      subroutine ldrivem(name,lsor,indxtp)
      integer indxtp,lsor
      character*(*) name
c
      integer nch
      integer*2 ib(50)
c
      include '../include/fscom.i'
c
      nch=1
      nch=ichmv_ch(ib,nch,name)
      nch=ichmv_ch(ib,nch,'1')
c
      call ldriveall(ib,nch,indxtp)
c
      call logit3(ib,nch-1,lsor)
      nch=1
      nch=ichmv_ch(ib,nch,name)
      nch=ichmv_ch(ib,nch,'2')
c
      nch=mcoma(ib,nch)
      nch = nch + ib2as(iacttp(indxtp),ib,nch,z'8003')
      call logit3(ib,nch-1,lsor)
c
      return
      end





