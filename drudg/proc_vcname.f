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
      subroutine proc_vcname(kk4vcab,code,vcband,cnamep)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'

! passed
      logical kk4vcab
      character*2 code          !code
      real vcband               !Bandwidth
! returned
      character*12 cnamep
! funcions
      character*1 cband_char

! local
      character*30 ctemp   !temporary array.
      integer nch

      if(kdbbc_rack) then
        cnamep="dbbc"
      else if(kbbc) then
        cnamep="bbc"
      else if(kifp) then
        cnamep="ifp"
      elseif (kvc) then
        cnamep="vc"
      endif

      ctemp=cnamep//code//cband_char(vcband)
      call squeezeleft(ctemp,nch)
      nch=nch+1
      cnamep=ctemp
      if (kk4vcab.and.krec_append) cnamep(nch:nch)=crec(irec)
      call lowercase(cnamep)
      return
      end

