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
      subroutine F_READSTRING(IDCB,IERR,CBUF,ILEN)

C INPUT:
C  IDCB: Control Block
C  IERR: Error value

C OUTPUT:
C  ILEN: Length in characters of input

C OTHER:
C  CBUF: Character buffer used in input
C  trimlen: find number of characters read from file
C
C  weh 950826 f2c apparently triggers end= on a read if there is no newline
C                 at the end of the last line. The kludge around this problem
C                 is to preset the buffer being read to a NULL followed by
C                 blanks, since this routine is nominally used to read text,
C                 a record with this content should never be returned
C
      integer IDCB
      integer IERR
      integer ILEN
      character*(*) CBUF
      integer trimlen

C Read in the buffer
 5    continue
      cbuf=char(0)
      read(IDCB,10,end=20,IOSTAT=IERR) CBUF
10    format(A)
 15   continue
      ILEN=trimlen(CBUF)
c defend against DOS line termination, cr/lf, the lf was striped by read()
      if(ilen.gt.0) then
         if(cbuf(ilen:ilen).eq.char(13)) then
            cbuf(ilen:ilen)=' '
            ilen=ilen-1
         endif
      endif
C If an error reset ilen to -1 since length is unknown
      if (IERR.ne.0) then
        ILEN=-1
        return
      else
        return
      end if
20    ILEN=-1
      IERR=0
      if(cbuf.ne.char(0)) goto 15
      cbuf=' '
      return
      end
