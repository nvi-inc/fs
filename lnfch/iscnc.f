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
      INTEGER FUNCTION ISCNC (LINPUT,IFC,ILC,LCH)
      IMPLICIT NONE
      INTEGER*2 LINPUT(1)
      integer IFC,ILC,LCH
C
C ISCNC: scan for character 
C
C Input:
C       LINPUT: Hollerith array to scan in
C       IFC:    character in LINPUT at which to start scan
C       ILC:    character in LINPUT at which to stop scan
C       LCH:    second byte contains character to scan for
C
C Output:
C       ISCNC: zero if LCH was not found in LINPUT
C              nonzero, the index at which the character was found
C              IFC <= ISCNC <= ILC in this case
C              if IFC > ILC then no-op
C
C Warning:
C       Negative and zero values of IFC or ICL are not supported
C
      INTEGER I
      character clch,cret,cjchar
      character*72 string
C
      IF(ILC.LE.0.OR.IFC.LE.0) THEN
	  WRITE(string,*) ' ISCNC: Illegal arguments',IFC,ILC
          call put_stderr(string//char(0))
          call put_stderr('\n'//char(0))
        STOP
      ENDIF
C
      clch = char(LCH)
      DO I=IFC,ILC
        cret = cjchar(linput,i)
        if ( clch .eq. cret) then
          ISCNC=I
	  RETURN
	ENDIF
      ENDDO
C
      ISCNC=0
C
      RETURN
      END
