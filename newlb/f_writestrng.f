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
      subroutine F_WRITESTRING(IDCB,IERR,CBUF,ILEN)

C INPUT:
C  IDCB: Control Block
C  IERR: Error value
C  CBUF: Character buffer to be written

C OUTPUT:
C  ILEN: Length in characters of input

C  trimlen: find number of characters read from file

      integer IDCB
      integer IERR
      integer ILEN
      character*(*) CBUF
      integer trimlen

5     write(IDCB,10,IOSTAT=IERR) CBUF
10    format(A)
      ILEN=trimlen(CBUF)
C If an error reset ilen to -1 since length is unwritten
      if (IERR.ne.0) then
        ILEN=-1
        return
      else
        return
      end if

      end
