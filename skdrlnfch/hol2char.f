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
      SUBROUTINE HOL2CHAR(IARR,IFC,ILC,CH)

      IMPLICIT NONE

      CHARACTER*(*) CH
      INTEGER*2 IARR(*)
! AEM 20041230 int*2->int
      integer IFC,ILC
C
C HOL2CHAR: move a Hollerith string into a character variable
C           blank filled to the right
C
C Input:
C       IARR: Hollerith string
C       IFC:  first character in IARR to move

C       ILC:  last character in IARR to move
C       CH:   destination character string
C
C Output:
C       CH: contains characters IFC...ILC from IARR
C           blank filled to the right if necessery
C
C  040506  ZMM  removed trailing RETURN
C               changed type from integer to integer*2

      integer ln,iend,i,IWORD,JCHAR
c     CHARACTER*1 CWORD(2)
c     EQUIVALENCE (CWORD(1),IWORD)
C
      LN=LEN(CH)
      IEND=MIN(LN,ILC-IFC+1)
C
      DO I=1,IEND
        IWORD=JCHAR(IARR,IFC+I-1)
	  CH(I:I)=char(iword)
      ENDDO
C
      IF(IEND.LT.LN) CH(IEND+1:)=' '
C
      END
