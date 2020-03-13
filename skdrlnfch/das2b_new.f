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
      double precision function das2b(ias,ic1,nch,ierr)
C     ascii to double precision binary
!   2006Aug02  Completely rewritten by JMGipson.  Old version crashed in some versions of unix.
!   2006Sep19  JMGipson.  Gave ctemp a size. Previously was dimensioned to char*(nch)
!
! AEM 20050111 add implicit none
      IMPLICIT NONE

      integer*2 ias(*)
      integer ic1,nch,ierr

C                   INPUT STRING WITH ASCII CHARACTERS
C     IC1 - FIRST CHARACTER TO USE IN IAS
C     NCH - NUMBER OF CHARACTERS TO CONVERT
C     IERR - ERROR RETURN, 0 IF OK, -1 IF ANY CHARACTER IS NOT A NUMBER
C
C     LOCAL VARIABLES
C
C     IFC - FIRST CHARACTER WHICH IS NOT + OR -
C     IEC - LAST CHARACTER TO BE CONVERTED
C     IDC - CHARACTER NUMBER OF DECIMAL POINT
C     NCINT - NUMBER OF CHARACTERS IN INTEGER PART
C     ISIGN - +1 OR -1

      integer i

      character*32 ctemp

! AEM 20050111 char->char*1
      character*1 cjchar
      
      if(nch .gt. 32) then
        write(*,*) "DAS2B: not enough space!"
        stop
      endif

! Get the character into ctemp
      ierr = 0
      if(ic1 .le. 0 .or. nch .le. 0) goto 100
      ctemp=" "

! Move the characters into the temporary string.
      do i=1,nch
        ctemp(i:i)=cjchar(ias,ic1+i-1)
      end do

! Use the fortran read statement
      read(ctemp,*,err=100) das2b
      return

100   continue
      ierr=-1
      return

      end
