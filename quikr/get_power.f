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
      subroutine get_power(oddeve,nsamp,volts,minper,ip,indxtp)
      implicit none
      integer oddeve,nsamp,ip(5),indxtp
      real*4 volts,minper
C
C GET_POWER: get read head detected power
C
C INPUT:
C   ODDEVE: odd or even power channel to use, odd for odd, even for even
C   NSAMP: number of samples to take
C
C OUTPUT:
C   VOLTS: largest power voltage measurement in NSAMP measurements
C   MINPER: percent of peak for smallest of NSAMP measurements
C   IP: Field System return parameters
C
      integer i,ichan
      real*4 vmax,vmin
C
      ichan=7-mod(oddeve,2)
      vmax=-20.0
      vmin=20.0
      call susp(1,50)
      do i=1,nsamp
        call get_atod(ichan,volts,ip,indxtp)
        if(ip(3).ne.0) return
C
        vmax=max(vmax,volts)
        vmin=min(vmin,volts)
C 50 millisecond between samples
        if(i.ne.nsamp) call susp(1,5)
      enddo
C
      volts=vmax
      if(vmax.le.0.0.or.vmin.le.0.0) then
        minper=0.0
      else
        minper=100.*(vmin/vmax)
      endif
C
      return
      end
