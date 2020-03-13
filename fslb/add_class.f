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
      subroutine add_class(ibuf,nch,iclass,nrec)
      implicit none
      integer*2 ibuf(1)
      integer nch,iclass,nrec
C
C  ADD_CLASS: Increment Class # Buffers
C
C  INPUT:
C     IBUF: buffer to add to class number
C     NCH: number of characters in IBUF
C     ICLASS: class # to add buffer, 0 to allocate new class #
C     NREC: number of records in class so far
C
C  OUTPUT:
C     ICLASS: new class # if 0 on entry
C     NREC: input NREC incremented by 1, new number of class records
C
      call put_buf(iclass,ibuf,nch,'fs','  ')
      nrec = nrec+1
      return
      end
