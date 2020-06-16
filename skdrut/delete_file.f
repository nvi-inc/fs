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
      subroutine delete_file(lfilnam,lutmp)
! Delete a file, and write an error message if a problem.
! 2017Dec04.  JMGipson. Some cleanup
      implicit none  !2020Jun15 JMGipson automatically inserted.
      integer lutmp
      character*(*) lfilnam
      integer ierr

! local
      logical kexist

      inquire(file=lfilnam,exist=kexist)
      if(.not. kexist) return

      OPEN (lutmp,  file=lfilnam,iostat=ierr)
      IF (ierr.NE.0) then
         WRITE(*,"('delete_file: I/O error ',i3, ' opening file ',a)")
     >    ierr,trim(lfilnam)
         return
      endif

      CLOSE (lutmp,status='delete',iostat=ierr)
      IF (ierr.NE.0) then
         WRITE(*,"('delete_file: I/O error ',i3, ' purging file ',a)")
     >    ierr,trim(lfilnam)
      endif


      return
      end
