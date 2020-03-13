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
      integer function jchar(iar,i)
C
C JCHAR: returns the Ith character (IN LOWER BIT) in hollerith array IAR
C 900807 MODIFIED TO FIT DOS BIT STORAGE (LOWER/UPPER) AS OPPOSED
C TO UNIX EQUIV. (UPPER/LOWER)

      implicit none
      integer*2 iar(1)
      integer F2,i,jishft
      data F2/Z'FF'/
C
      jchar=iar((i+1)/2)

c original coding
c      IF(MOD(I,2).EQ.1) JCHAR=ISHFT(JCHAR,-8)
C      JCHAR=IAND(JCHAR,F2)
c 900808 put char in DOS higher (RIGHT) bit - lower position
C storage: odd position on right bit, even position on left bit

      if(mod(i,2).eq.0) jchar=jishft(jchar,-8)
      jchar=and(jchar,F2)

      return
      end
