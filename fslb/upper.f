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
      subroutine upper(ibuf,ifc,ilc)

      implicit none
      integer*2 ibuf(1)
      integer ifc,ilc
      integer nchar,i,ival,jchar
c 
      nchar = ilc - ifc + 1
      if (nchar.le.0) return
      do i=ifc,ilc
        ival=jchar(ibuf,i)
        if (ival.ge.97.and.ival.le.122) then
           ival = ival-32
           call pchar(ibuf,i,ival)
        endif
      enddo

      return
      end
