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
      subroutine char2low(cbuf)

      implicit none
      character*(*) cbuf
      integer i,ival
      character ch
 
      if (len(cbuf).le.0) return
      do i=1,len(cbuf)
        ch = cbuf(i:i)
        ival=ichar(ch)
        if(ival.ge.65.and.ival.le.90) ch = char(ival+32)
        cbuf(i:i) = ch
      enddo

      return
      end
