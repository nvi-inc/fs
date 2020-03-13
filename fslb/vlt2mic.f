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
      subroutine vlt2mic(ihead,ipass,kauto,volt,micron,ip,indxtp)
      integer ihead,ip(5),ipass,indxtp
      real*4 micron,volt
      logical kauto
C
C  VLT2MIC: convert voltage to micron position
C
C  INPUT:
C     IHEAD - head voltage being converted
C     IPASS - pass number assumed, 0 = uncalibarted
C             odd,  use forward calibration
C             even, use reverse calibration
C     KAUTO - if write head should have pitch adjusted
C     VOLT - voltage to convert
C
C  OUTPUT:
C     MICRON - microns corresponding to input
C     IP(5) - Field System return parameters
C             currently unused
C
      include '../include/fscom.i'
C
      if(volt.ge.0.0) then
        micron=volt*pslope(ihead,indxtp)
      else
        micron=volt*rslope(ihead,indxtp)
      endif
      if(ipass.ne.0) then
         if(ihead.eq.1) then
            if(kauto) then
               call fs_get_wrhd_fs(wrhd_fs,indxtp)
               ipitch=wrhd_fs(indxtp)
            else
               ipitch=0
            endif
         else
            call fs_get_rdhd_fs(rdhd_fs,indxtp)
            ipitch=rdhd_fs(indxtp)
         endif
        call fs_get_drive(drive)
        if(drive(indxtp).eq.VLBA.or.drive(indxtp).eq.VLBA4) then
           if(mod(ipass,2).eq.0) then
              if(ipitch.eq.2) micron=micron-698.5
           else
              if(ipitch.eq.1) micron=micron+698.5
           endif
        else
           if(mod(ipass,2).eq.0) then
              if(ipitch.eq.1) micron=micron-698.5
           else
              if(ipitch.eq.2) micron=micron+698.5
           endif
        endif
        micron=micron-foroff(ihead,indxtp)
        if(mod(ipass,2).eq.0) micron=micron-revoff(ihead,indxtp)
      endif
C
      return
      end
