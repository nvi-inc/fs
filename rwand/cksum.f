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
      logical function cksum(bufr,nchar)
C  Check the sum of characters received from the TimeWand. 
C                                                Lloyd Rawley   March 1988
C  Input parameters:
      integer*2 bufr(1)           !  buffer received from the wand
      integer nchar             !  number of characters in buffer
      integer*2 lcrcr
      integer icompare, ichcm, ia2hx 
      integer*2 icheck, isum
      integer*2 lbyte, mbyte
C
C  Output value:  TRUE if check works, FALSE if it fails
C
C  Method:  The last five bytes of the buffer sent by the wand contain three
C           carriage returns and a two-digit hexadecimal value which should
C           be the sum of the binary values of the characters sent before
C           (other than carriage returns).
C
C  Subroutines called:  Lee Foster's character routines,
C                       HP bit manipulation routines
C
C 1. Check that last five bytes are in the form expected.
C
      lcrcr = z'0D0D'     !  (two carriage returns.)
      icompare = ichcm(lcrcr,1,bufr,nchar-4,2)
      i16 = ia2hx(bufr,nchar-2)             !  convert ascii hex to binary;
      i1  = ia2hx(bufr,nchar-1)             !  -1 returned if out of range. 
      if (i16.eq.-1 .or. i1.eq.-1 .or. icompare.ne.0) then
        cksum = .false.
        return                              !  string was probably truncated.
      endif
C
      icheck = and((16*i16)+i1,z'FF')
C
C 2. Add up all previous bytes and compare to value obtained above.
C
      isum = 0
      nwords = (nchar-4)/2
      do i=1,nwords
        lbyte = and(bufr(i),z'FF')
        if (lbyte.eq.z'0D') lbyte=0
        mbyte = rshift(bufr(i),8)
        if (mbyte.eq.z'0D') mbyte=0
        isum = and(lbyte+mbyte+isum,z'FF')
      end do

      cksum = (isum.eq.icheck)
C
      return
      end
