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
      function ihx2a(inum)

C     CONVERT INUM TO A HEX CHARACTER, RETURNED IN LOWER BYTE 

cxx      dimension lhex(8) 
      character*16 lhex
      data lhex/'0123456789abcdef'/
C 
      ihx2a = 0 
      if (inum.lt.0.or.inum.gt.15) return 
      call char2hol(lhex(inum+1:inum+1),ihx2a,2,2)
cxx      ihx2a = jchar(lhex,inum+1)

      return
      end 
