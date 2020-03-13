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
        subroutine ifill_ch(iout,ic,nc,ch)

        implicit none
        integer ic,nc
! AEM 20041230 int->int*2
        integer*2 iout(*)
! AEN 20041230 char->char*1
        character*1 ch
C
C IFILL: fill array IOUT with from character IC through IC+NC-1 inclusive
C        with the character in ch.
C
C Input:
C       IOUT: hollerith array to be filled
C       IC:   first character in IOUT to fill
C       NC:   number of characters in IOUT to fill
C       CH:   lower byte contains fill character
C
C Output:
C        IOUT: characters IC...IC+NC-1 filled with CH
C              NC .eq. 0 then no-op
C
C Warning:
C         Negative and zero values of IC are not support
C         NCHAR must be non-negative
C
      INTEGER I
C
      IF(IC.LE.0.OR.NC.LT.0) THEN
	  WRITE(6,*) ' IFILL_CH: Illegal arguments',IC,NC
        STOP
      ENDIF
C
      IF(NC.EQ.0) RETURN
C
      do i=0,nc-1
        call char2hol(ch,iout,ic+i,ic+i)
      enddo
C
! AEM 20041230 commented return
!      return
      end
