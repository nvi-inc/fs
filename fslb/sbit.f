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
      subroutine sbit(iarray,ibit,ival) 
      implicit none
      integer iarray(1),ibit,ival
c 
c   sbit sets (or resets) the ibit-th bit of iarray if ival is one
c   (or zero). sbit uses the same bit numbering convention as kbit.
c   values of ival other than 1 or 0 are no-ops.
c
      include '../include/params.i'
c
      integer ib,iw,jibset,jibclr
c 
      iw = ((ibit-1)/INT_BITS)+1
      ib = ibit - (iw-1)*INT_BITS
c 
      if (ival.eq.1) then
         iarray(iw)=jibset(iarray(iw),ib-1)
      else if(ival.eq.0) then
         iarray(iw)=jibclr(iarray(iw),ib-1)
      endif
c
      return
      end 
