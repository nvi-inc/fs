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
      implicit none  !2020Jun15 JMGipson automatically inserted.
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
! 2009Oct12  JMG. Modified because with large networks (>26) was getting strange characters
!            Now tries to find free space among approved list of character letters.
!
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
      integer max_valid
      parameter (max_valid=72)

      character*(max_valid) cvalid
      character*1 cvec(max_valid)
      equivalence (cvec,cvalid)
      integer itry


C     inum - number of entries in array
C     cstnid - array with entries
C
C   SUBROUTINES
C     CALLED BY: AWRST
C     CALLED: CHAR2HOL,HOL2CHAR
C
C  LOCAL VARIABLES
      integer iwhere
      cvalid=
     >"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"//      !36
     >"@#$%<>[]()abcdefghijklmnopqrstuvwxyz"      !36

      itry=0
      if(inum .le. 1) then
        return
      else
! First check to see if name is valid.
        iwhere=iwhere_in_string_list(cvalid,max_valid,cstnid(inum))
        if(iwhere .eq. 0) then   !not valid.  Set it to the first valid character
            cstnid(inum)=cvec(1)
        endif
        if(inum .eq. 1) return

! Now make sure character is unique.
        iwhere =1
! search for match among earlier entries
        do while(iwhere .ne. 0)
          iwhere=iwhere_in_string_list(cstnid,inum-1,cstnid(inum))
          if(iwhere .ne. 0) then                        !A match.
             itry=itry+1
             if(itry .gt. max_valid) then
                write(*,*) "IDCHK: No more 1 character station IDs"
                stop
             endif
             cstnid(inum) = cvec(itry)
          endif
        end do
      endif

      RETURN
      END
