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
      subroutine reado(ivexnum,istn,lu,iret,ierr)

C     READO calls the routines to read a observations
C     from a VEX file.

C History
C 960531 nrv New.

C Input
      character*(*) cfile ! VEX file path name

C Output
      integer iret ! error return from VEX routines
      integer ierr ! error return, non-zero

C Local
      integer fvex_open,ptr_ch

C  1. Read the observations for one station.

      call vob1inp(ivexnum,istn,lu,ierr) ! observations
      if (ierr.ne.0) then
        write(lu,'("READV04 - Error reading observations.")')
      endif

      return
      end
