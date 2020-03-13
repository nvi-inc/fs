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
      subroutine set_vlt(ihead,volt,ip,tol,indxtp)
      implicit none
c
      include '../include/fscom.i'
c
      integer ihead,ip(5),ips(5),indxtp
      real*4 volt(2),tol
C
C  SET_VLT: set head(s) to (a) particular voltage(s)
C
C  INPUT:
C     IHEAD: head number to move: 1, 2, or 3 (both)
C     VOLT: voltage to set the head(s) to
C
C  OUTPUT:
C     IP: Field System return parameters
C       IP(3) = 0 if no error
C
      ips(3)=0
c
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if(ihead.eq.3 .and. .not.
     &     (drive(indxtp).eq.VLBA4.and.drive_type(indxtp).eq.VLBA42)
     &     ) then
        call head_vlt(2,0.0,ip,1498.5,indxtp) !1498.5 ~= 9.9902*150
        if(ip(3).ne.0) then
          ips(1)=ip(1)
          ips(2)=ip(2)
          ips(3)=ip(3)
          ips(4)=ip(4)
          ips(5)=ip(5)
          ip(3)=0
        endif
        call head_vlt(1,0.0,ip,1498.5,indxtp) !1498.5 ~= 9.9902*150
        if(ip(3).ne.0) then
           if(ips(3).ne.0) then
              call logit7(0,0,0,0,ips(3),ips(4),ips(5))
              return
           endif
        endif
      endif
C
      if(ihead.ne.1) then
        call head_vlt(2,volt(2),ip,tol,indxtp)
        if(ip(3).ne.0) then
          ips(1)=ip(1)
          ips(2)=ip(2)
          ips(3)=ip(3)
          ips(4)=ip(4)
          ips(5)=ip(5)
          ip(3)=0
        endif
      endif
C
      if(ihead.ne.2) then
        call head_vlt(1,volt(1),ip,tol,indxtp)
        if(ip(3).ne.0) then
           if(ips(3).ne.0) then
              call logit7(0,0,0,0,ips(3),ips(4),ips(5))
              return
           endif
        endif
      endif
C
      if(ips(3).ne.0) then
        ip(1)=ips(1)
        ip(2)=ips(2)
        ip(3)=ips(3)
        ip(4)=ips(4)
        ip(5)=ips(5)
      endif
c
      return
      end
