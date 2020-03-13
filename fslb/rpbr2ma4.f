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
      subroutine rpbr2ma4(ibuf,ibr,ivac)
C     convert repro's bitrate data to mat buffer for Mark IV drive.
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
C     IBR - bitrate selection
C 
C     Format the buffer for the controller. 
C 
      call ichmv_ch(ibuf,1,'.') 
C                   The strobe character for this control word
      call ichmv_ch(ibuf,2,'00000004') 
C                   Fill buffer with zeros to start except
C                   final position is always 4.
      call ichmv(ibuf,6,ihx2a(ivac*4),2,1)
      if(ibr.lt.0.or.ibr.gt.15) then
         ibrx=3
      else
         ibrx=ibr
      endif
      call ichmv(ibuf,8,ihx2a(ibrx),2,1)
C
      return
      end 
