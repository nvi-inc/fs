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
      subroutine run_matcn(iclass,nrec)

      implicit none
      integer iclass,nrec,idum
      data idum/0/
C
C  RUN_MATCN: run MATCN and clean up as necessary
C
C  INPUT:
C     ICLASS: class number containing messages, 0 if none
C     NREC: number of records in class
C
C  OUTPUT:
C
C      integer ifbrk
C
      call run_prog('matcn','wait',iclass,nrec,idum,idum,idum)
C
      return
      end
