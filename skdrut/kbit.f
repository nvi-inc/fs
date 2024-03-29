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
      logical function kbit(iarray,ibit)
      implicit none
      integer iarray(*),ibit
c 
c  kbit is true if the ibit-th bit of iarray is set, false otherwise
c  the first max_int_bits are in the first int of the array,
c  the second max_int_bits are in the second int of the array
c  within an int the bits are numbered such that if i (range 1 to
c  and including max_int_bits) is the only bit the set in the int,
c  the int equals 2**(i-1)
c  kbit is designed to complement sbit which sets or resets 
c  bits identified in the same way. 
c
c     include '../include/params.i'
!2020-12-30 JMG Removed unsed variable
C NRV 951015 set variable INT_BITS instead
      integer INT_BITS
c 
      integer ib,iw

c 
      INT_BITS=32
      iw = ((ibit-1)/INT_BITS)+1
      ib = ibit - (iw-1)*INT_BITS
c 
      kbit = btest(iarray(iw),ib-1) 
c 
      return
      end 
