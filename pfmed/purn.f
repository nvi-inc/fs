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
      subroutine purn(lui,lnam1,lproc,lstp,lprc,pathname,ierr)
C
C  THIS SUBROUTINE WAS WRITTEN FOR USE BY THE PFMED COMMANDS
C  PFRN AND PFPU. IT MAKES THE FOLLOWING CHECKS: ACTIVE FILES
C  FOR PFMED AND OPRIN, FILE EXISTENCE, AND "STATION" PROCEDURE
C  FILE. IT RETURNS A -1 IN IERR AFTER A TRUE ERROR REPORT.
C
C  INPUT PARAMETERS
      character*12 lnam1,lproc,lstp,lprc
      character*28 pathname
C  OUTPUT PARAMETERS
      integer ierr
C
C  LOCAL VARIABLES
      logical kex
      integer nch,trimlen
C
C  WHO  WHEN    DESCRIPTION
C  GAG  910318  CREATED
C
  
      ierr = 0
      if (lnam1.ne.lproc) then
        inquire(file=pathname,exist=kex)
        if (.not.kex) then
          nch=trimlen(pathname)
          write(lui,1101) pathname(:nch)
1101      format(" file ",a," does not exist")
          ierr = -1
          return
        end if
      else
        write(lui,9100)
9100    format(" cannot perform operation on open pfmed library")
        ierr = -1
        return
      end if
      if (lnam1.eq.lstp) then
        write(lui,9200)
9200    format(" cannot perform operation on current station library")
        ierr = -1
        return
      endif
      if (lnam1.eq.lprc) then
        write(lui,9300)
9300    format(" cannot perform operation on current field system"
     .         " proc library")
        ierr = -1
        return
      endif
  
      return
      end
