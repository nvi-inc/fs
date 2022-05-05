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
      subroutine hol2lower(iarr,ilen)
      implicit none
c
c Convert any upper case to lower.
C 930601 NRV Input is hollerith. In this routine, change to a
C            string, convert, then change back.
C 960213 nrv Make local string bigger
c
C Input:
      integer*2 iarr(*)!NOTE: iarr is modified upon return
      integer ilen ! length in characters
C Local:
      integer i,ival
C ***********NOTE*********** change this when ibuf is changed
      character*1024 string
c
      call hol2char(iarr,1,ilen,string)
      do i=1,ilen
        ival=ichar(string(i:i))
        if(ival.ge.65.and.ival.le.90) string(i:i)=char(ival+32)
      enddo
      call char2hol(string,iarr,1,ilen)
c
      return
      end

