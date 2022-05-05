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
      subroutine ma2rpbr4(ibuf,ibr)
C     convert mat buffer data to repro4's bitrate data to 
C     for Mark IV drive.
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
C     IBR - bitrate selection
C 
      call ichmv(itemp,1,ibuf,9,1) 
      ibr = ia2hx(itemp,1)
C
      return
      end 
