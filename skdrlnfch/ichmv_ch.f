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
       integer FUNCTION ICHMV_CH (LOUT,IFC,CINPUT)

       IMPLICIT NONE
       integer IFC
! AEM 20041230 int->int*2
       integer*2 LOUT(*)
       character*(*) CINPUT
C
C ICHMV: Hollerith character string mover
C
C Input:
C        LOUT: destination array
C        IFC: first character to fill in LOUT
C        CINPUT: source array
C
C Output:
C         ICHMV: IFC+LEN(CINPUT) (next available character)
C         LOUT: characters starting at IFC contain
C               characters from CINPUT
C
C Warning:
C         Negative and zero values of IFC are not support
C
      integer NCHAR
C
      IF(IFC.LE.0) THEN
	  WRITE(6,*) ' ICHMV_CH: Illegal argument',IFC
        STOP
      ENDIF
C
      NCHAR=LEN(CINPUT)
      call char2hol(CINPUT,LOUT,IFC,IFC+NCHAR-1)
C
      ICHMV_CH=IFC+NCHAR
C
! AEM 20041230 commented return
!      RETURN
      END
