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
      subroutine putb(ibuf,n,i) 
C 
C     ROUTINE TO SET/CLEAR BIT N IN ARRAY IBUF. 
C     LSB OF I SETS/CLEARS SPECIFIED BIT. HIGHER ORDER BITS IN I ARE IGNORED. 
C     FIRST BIT IN IBUF IS BIT #1.
C 
      integer*2 ibuf(1) 
      integer*2 j,iibset
      integer is
C 
      nw=(n+15)/16
      ibit=mod(n-1,16)+1
      j=ibuf(nw)
      if (and(i,1) .ne. 0) then
C     SET BIT 
        if(ibit.le.8) then
          is=8-ibit
          ibuf(nw)=iibset(j,is)
        else
          is=24-ibit
          ibuf(nw)=iibset(j,is)
        endif
      else 
        if(ibit.le.8) then
          is=8-ibit
          ibuf(nw)=iibclr(j,is)
        else
          is=24-ibit
          ibuf(nw)=iibclr(j,is)
        endif
      endif
C110  WRITE(16,105) N,I,NW,IBIT,IBUF(NW)
C105  FORMAT("N,I,NW,IBIT,IBUF(NW)=",4I6,O8)
      return
      end 
