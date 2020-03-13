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
      subroutine ldriveall(ib,nch,indxtp)
      integer*2 ib(1)
      integer nch,indxtp
c
c
      include '../include/fscom.i'

      nch=mcoma(ib,nch)
      call fs_get_imaxtpsd(imaxtpsd,indxtp)
      if (imaxtpsd(indxtp).eq.-2) then
        nch = nch + ib2as(360,ib,nch,3)
      else if (imaxtpsd(indxtp).eq.-1) then
        nch = nch + ib2as(330,ib,nch,3)
      else if (imaxtpsd(indxtp).eq.7) then
        nch = nch + ib2as(270,ib,nch,3)
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_iskdtpsd(iskdtpsd,indxtp)
      if (iskdtpsd(indxtp).eq.-2) then
        nch = nch + ib2as(360,ib,nch,3)
      else if (iskdtpsd(indxtp).eq.-1) then
        nch = nch + ib2as(330,ib,nch,3)
      else if (iskdtpsd(indxtp).eq.7) then
        nch = nch + ib2as(270,ib,nch,3)
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_vacsw(vacsw,indxtp)
      if (vacsw(indxtp).eq.1) then
         nch=ichmv_ch(ib,nch,'yes')
      else if (vacsw(indxtp).eq.0) then
         nch=ichmv_ch(ib,nch,'no')
      endif
c
      return
      end
