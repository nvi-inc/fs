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
      subroutine vlt_read(ihead,volt,ip,indxtp)
      implicit none
      integer ihead,ip(5),indxtp
      real*4 volt(2)
C
C  VLT_READ: read head vaoltage(s)
C
C  INPUT:
C     IHEAD: Head to read voltage of: 1, 2, or 3 (both)
C
C  OUTPUT:
C     VOLT(2): voltage or voltages (1), (2), or both
C     IP - Field System return parameters
C     IP(3) = 0, if no error
C
      integer i
C
      do i=1,2
        if(i.eq.ihead.or.ihead.eq.3) then
          call vlt_head(i,volt(i),ip,indxtp)
          if(ip(3).ne.0) return
        endif
      enddo
C
      return
      end
