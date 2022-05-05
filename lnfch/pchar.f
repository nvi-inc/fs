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
      SUBROUTINE PCHAR(IAR,I,ICH)
      IMPLICIT NONE
      INTEGER*2 IAR(1)
      integer I,ICH
C
C PCHAR: puts the character in the lower byte (DOS) of ICH into the
C        Ith position in array IAR
C 900807 MODIFIED WITH 'JCHAR' TO DOS BIT STORAGE (LOWER/UPPER) AS
C OPPOSED TO UNIX EQUIV. (UPPER/LOWER)
C storage: odd position on right bit, even position on left bit
      INTEGER IWORD,NWORD
C ADDED 900625
      INTEGER F2,FOOF,jishft
      DATA F2/Z'FF'/, FOOF/Z'FF00'/
c
      IWORD=IAR((I+1)/2)
c assumes ich placed in DOS upper (right) bit
      IF(MOD(I,2).EQ.1) THEN
        IWORD=AND(IWORD,FOOF)
        NWORD=AND(ICH,F2)
      ELSE
        IWORD=AND(IWORD,F2)
        NWORD=JISHFT(ICH,8)
c original coding
C       IF(MOD(I,2).EQ.1) THEN
C         IWORD=IAND(IWORD,F2)
C         NWORD=ISHFT(ICH,8)
C       ELSE
C         IWORD=IAND(IWORD,FOOF)
C         NWORD=IAND(ICH,F2)
C
      ENDIF
      IAR((I+1)/2)=OR(IWORD,NWORD)
C
      RETURN
      END
