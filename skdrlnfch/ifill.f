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
        SUBROUTINE IFILL(IOUT,IC,NC,JC)

        IMPLICIT NONE
        integer*2 iout(*)
        INTEGER IC,NC,JC
C
C IFILL: fill array IOUT with from character IC through IC+NC-1 inclusive
C        with the character in th lower byte of JC
C
C Input:
C       IOUT: hollerith array to be filled
C       IC:   first character in IOUT to fill
C       NC:   number of characters in IOUT to fill
C       JC:   lower byte contains fill character
C
C Output:
C        IOUT: characters IC...IC+NC-1 filled with lower byte of JC
C              NC .eq. 0 then no-op
C
C Warning:
C         Negative and zero values of IC are not support
C         NCHAR must be non-negative
C         IC+NCHAR.LE.32767
C
      INTEGER I,IEND
C
      IF(IC.LE.0.OR.NC.LT.0) THEN
	  WRITE(6,*) ' IFILL: Illegal arguments',IC,NC
        STOP
      ENDIF
C
      IF(NC.EQ.0) RETURN
C
      IEND=32767-NC+1
C
      IF(IC.GT.IEND) THEN
	  WRITE(6,*) ' IFILL: Illegal combination',IC,NC
        STOP
      ENDIF
C
      DO I=0,NC-1
        CALL PCHAR(IOUT,IC+I,JC)
      ENDDO
C
! AEM 20041230 commented return
!      RETURN
      END
