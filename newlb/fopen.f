*
* Copyright (c) 2020, 2023  NVI, Inc.
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
      subroutine fopen(idcb,filename,ierr)

C Subroutine to open a file

C INPUT:
C  IDCB: Control Block of File

C OUTPUT:
C  IERR: Error value, returns negative if an error is detected

      include '../include/boz.i'
C
      integer IDCB
      character*(*) filename
      integer IERR
      integer permissions
      integer ilen, trimlen
      logical kexist
     
      INQUIRE(FILE=filename,EXIST=kexist,IOSTAT=IERR)
      IF (IERR.GT.0) THEN
        IERR=-1                   !  Indicates that an error has occured
        return
      END IF
      OPEN(IDCB,FILE=filename,IOSTAT=IERR)
      IF (IERR.GT.0) THEN
        IERR=-1                   !  Indicates that an error has occured
        return
      END IF
      IF(.not.kexist) then
         permissions = ocp0664
         ilen=trimlen(filename)
         call fc_chmod(filename,permissions,ilen,ierr)
      endif

      return
      end
