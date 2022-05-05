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
      function ia2hx(lbuf,ich)

C     CONVERT HEX CHARACTER ICH OF LBUF TO BINARY 

      integer*2 lbuf(1)
      integer jchar
      dimension ival(23)
      data ival/0,1,2,3,4,5,6,7,8,9,7*0,10,11,12,13,14,15/  

      lch = jchar(lbuf,ich) 
C                   Extract the character 
      ia2hx = -1
C               <0     OR      >F   OR       (>9 AND <A)
      if (lch.ge.o'141'.and.lch.le.o'146') lch = lch - o'40'
C          if lower case a ... f, change to upper
      if (lch.lt.o'60'.or.lch.gt.o'106'.or.(lch.gt.o'71'.and.
     .    lch.lt.o'101'))  return
      ia2hx = ival(lch-o'57') 

      return
      end 
