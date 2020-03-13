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
      subroutine READG(IDCB,IERR,IBUF,ILEN)

C INPUT:
C  IDCB: Control Block
C  IERR: Error value
C  IBUF: Buffer for read

C OUTPUT:
C  ILEN: Length in characters of input

C OTHER:
C  CBUF: Character buffer used in input

      integer IDCB(1)
      integer IERR
      integer ILEN
      integer IBUF(1)
      character*100 CBUF
      integer fmpreadstr

5     ilen = fmpreadstr(IDCB,IERR,CBUF)
      if ((IERR.ne.0).or.(ilen.eq.-1)) then
        ILEN=-1
        return
      endif
 
      IF((CBUF(1:1) .EQ. '*') .OR. (ILEN.EQ.0)) GOTO 5

      call char2hol(CBUF,IBUF,1,ILEN)
c
      IERR=0

      return
      end
