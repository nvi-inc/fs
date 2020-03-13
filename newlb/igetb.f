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
      integer function igetb(ibuf,n)
C 
C     ROUTINE TO RETURN VALUE OF Nth BIT IN ARRAY IBUF. 
C     FIRST BIT IS BIT #1.
C 
      integer*2 ibuf(1)
      integer*2 mask(16)
      
c      DATA MASK/100000B,40000B,20000B,10000B,4000B,2000B,1000B, 
c     .          400B,200B,100B,40B,20B,10B,4B,2B,1B/
      data mask/
     .o'200',o'100',o'40',o'20',o'10',o'4',o'2',o'1',
     .o'100000',o'40000',o'20000',o'10000',o'4000',o'2000',o'1000',
     .  o'400'
     ./
C 
      nn=n-1
      iw=nn/16+1
      igetb=0 
      if (and(ibuf(iw),mask(mod(nn,16)+1)).ne.0) igetb=1 

      return
      end 
