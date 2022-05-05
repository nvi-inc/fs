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
       integer FUNCTION ichmv (LOUT,IFC,LINPUT,ICL,NCHAR)
       
! AEM comment: function returns position of next character

       IMPLICIT NONE
       integer IFC,ICL,NCHAR
! AEM 20041230 int->int*2
       integer*2 LOUT(*),LINPUT(*)

C
C ichmv: Hollerith character string mover
C
C Input:
C        LOUT: destination array
C        IFC: first character to fill in LOUT
C        LINPUT: source array
C        ICL: first character to move from LINPUT
C        NCHAR: number of characters to move
C
C Output:
C         ichmv: IFC+NCHAR (next available character left-to-right)
C         LOUT: characters IFC...IFC+NCHAR-1 contain
C               characters ICL...ICL+NCHAR-1 from LINPUT
C               IF NCHAR.eq.0 then no-op.
C
C Warning:
C         Negative and zero values of IFC or ICL are not support
C         NCHAR must be non-negative
C         IFC+NCHAR.LT.32767
C         ICL+NCHAR.LE.32767
C
      integer I,IEND,JCHAR
C
      IF(ICL.LE.0.OR.IFC.LE.0.OR.NCHAR.LT.0) THEN
	  WRITE(6,*) ' ichmv: Illegal arguments',IFC,ICL,NCHAR
        STOP
      ENDIF
C
      IF(NCHAR.EQ.0) then
        ichmv=IFC
        RETURN
      ENDIF
C
! AEM comment: very funny condition :)
      IEND=32767-NCHAR+1
C
      IF(IFC.GE.IEND.OR.ICL.GT.IEND) THEN
	  WRITE(6,*) ' ichmv: Illegal combination',IFC,ICL,NCHAR
        STOP
      ENDIF
C
      DO I=0,NCHAR-1
        CALL PCHAR(LOUT,IFC+I,JCHAR(LINPUT,ICL+I))
      ENDDO
C
      ichmv=IFC+NCHAR
C
! AEM 20041230 commented return
!      RETURN
      END
