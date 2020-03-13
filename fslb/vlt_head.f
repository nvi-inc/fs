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
      subroutine vlt_head(ihead,volt,ip,indxtp)
      implicit none
C
      include '../include/fscom.i'
c
      integer ihead,ip(5),indxtp
      real*4 volt
C
C  VLT_HEAD: get head position in volt units
C
C  INPUT:
C     IHEAD - IHEAD to get position of, 1 or 2
C
C  OUTPUT:
C    VOLT - voltage position of head
C    IP - FIeld System return parameters
C    IP(3) = 0 if no error
C
      call fs_get_drive_type(drive_type)
      call fs_get_drive(drive)
      call fs_get_reccpu(reccpu,indxtp)
      if((drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBA2).or.
     *   (drive(indxtp).eq.VLBA4.and.drive_type(indxtp).eq.VLBA42)) then
        call fc_v2_vlt_head(ihead,volt,ip,indxtp)
      else if((drive(indxtp).eq.VLBA.or.drive(indxtp).eq.VLBA4).and.
     &       reccpu(indxtp).eq.162) then
         call v_vlt_head(ihead,volt,ip,indxtp)
      else
        call get_atod(ihead,volt,ip,indxtp)
      endif
C
      return
      end
