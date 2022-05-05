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
      SUBROUTINE idchk(inum,cstnid,luscn)
C
C  This subroutine checks for identical station id characters and
C  replaces the second with the next character alphabetically.
C
C
C   HISTORY:
C
C     WHO   WHEN   WHAT
C     gag   900104 created
C 960206 nrv Variable holding station id must be i*2
C 970513 nrv Remove printout because it's confusing and not
C            really needed with 2-letter code usage.
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
C     include 'skcom.ftni'
C
C  INPUT:
C
      integer luscn,inum
      character cstnid(max_stn)
! function
      integer iwhere_in_string_list

C     inum - number of entries in array
C     cstnid - array with entries
C
C   SUBROUTINES
C     CALLED BY: AWRST
C     CALLED: CHAR2HOL,HOL2CHAR
C
C  LOCAL VARIABLES
      integer iwhere

      if(inum .le. 1) then
        return
      else
        iwhere=1
! search for match among earlier entries
        do while(iwhere .ne. 0)
          iwhere=iwhere_in_string_list(cstnid,inum-1,cstnid(inum))
          if(iwhere .ne. 0) then                        !A match.
             cstnid(inum)=char(ichar(cstnid(inum))+1)   !Change the 1 char ID.
          endif
        end do
      endif

      RETURN
      END
