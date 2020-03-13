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
      INTEGER FUNCTION iscn_ch(LINPUT,IFC,ILC,CCH)
      IMPLICIT NONE
      INTEGER IFC,ILC
! AEM 20050111 int->int*2
      INTEGER*2 LINPUT(*)
      CHARACTER*(*) CCH
C
C iscn_ch: scan for character string
C
C Input:
C       LINPUT: Hollerith array to scan in
C       IFC:    character in LINPUT at which to start scan
C       ILC:    character in LINPUT at which to stop scan
C       CCH:    contains character string to scan for
C
C Output:
C       iscn_ch: zero if CCH was not found in LINPUT
C              nonzero, the index at which the character was found
C              IFC <= iscn_ch <= ILC in this case
C              if IFC > ILC then no-op
C
C Warning:
C       Negative and zero values of IFC or ICL are not supported
C
      INTEGER I,j
! AEM 20050111 char->char*1
      character*1 ch
C
      IF(ILC.LE.0.OR.IFC.LE.0) THEN
        WRITE(6,*) ' ISCN_CH: Illegal arguments',IFC,ILC
        STOP
      ENDIF
C
      DO I=IFC,ILC-len(cch)+1
        call hol2char(LINPUT,i,i,ch)
        IF(CCH(1:1).EQ.ch) THEN
           do j=2,len(cch)
              call hol2char(linput,i+j-1,i+j-1,ch)
              if(cch(j:j).ne.ch) goto 100
           enddo
           iscn_ch=I
           RETURN
        ENDIF
 100    continue
      ENDDO
C
      iscn_ch=0
C
! AEM 20050111 commented return
!      RETURN
      END
