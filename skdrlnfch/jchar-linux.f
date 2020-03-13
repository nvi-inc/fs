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
      function jchar(iar,i)
C
C JCHAR: returns the Ith character (IN LOWER BIT) in hollerith array IAR
C 900807 MODIFIED TO FIT DOS BIT STORAGE (LOWER/UPPER) AS OPPOSED
C TO UNIX EQUIV. (UPPER/LOWER)

      implicit none
!      integer*2 iar(1)
!      integer F2,i,jishft

! AEM 20050112 int->int*2, add 'very_temp' to use instead 'jchar'
      integer*2 iar(*),F2,very_temp
      integer i,jchar
!
      data F2/Z'FF'/
C
      very_temp = iar((i+1)/2)

c original coding
c      IF(MOD(I,2).EQ.1) JCHAR=ISHFT(JCHAR,-8)
C      JCHAR=IAND(JCHAR,F2)
c 900808 put char in DOS higher (RIGHT) bit - lower position
C storage: odd position on right bit, even position on left bit

! AEM 20041206 jishft -> ishft
      if(mod(i,2).eq.0) very_temp = ishft(very_temp,-8)
! AEM 20041206 AND->IAND      
      very_temp = iand(very_temp,F2)
      
      jchar = very_temp

! AEM 20050112 commented return
!      return
      end
