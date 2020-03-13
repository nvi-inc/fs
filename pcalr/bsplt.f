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
      subroutine bsplt(idata,ilog)
C 
C     BSPLT separates the data from the A and B channels, 
C     which is necessary to process split mode data.
C 
C  INPUT: 
      dimension idata(1)
C      - IDATA holds the data in the form 1 byte A, 1 byte B etc. 
C     ILOG - # of characters in IDATA 
C 
C  OUTPUT:
C     IDATA - reformatted to hold all channel B bytes and then
C     all channel A bytes.
C 
C  LOCAL: 
      dimension itemp(260)
C      - buffer to save IDATA whilst reformatting 
C 
C     MAH - 19820217
C 
      do i = 1,ilog/2 
        itemp(i) = idata(i) 
      enddo
C 
      do i = 1,ilog/2 
        call ichmv(idata,i,itemp,2*i,1) 
      enddo
C 
      do i=1,ilog/2 
        call ichmv(idata,ilog/2+i,itemp,2*i-1,1)
      enddo
C 
      return
      end 
