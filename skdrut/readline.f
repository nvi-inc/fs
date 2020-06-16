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
      SUBROUTINE READline(IUNIT,lstring,keof,ierr,imode)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C  READS reads the schedule file lines.
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer iunit     !lu unit
      integer imode
      character*(*) lstring  !string to read lineinto
C     IMODE - mode for reading
C             1 = get the next record with $ in column 1
C             2 = get the next non-comment, stop when a record
C                 with $ in col. 1 is encountered.
C                 A comment card has * in column 1
C
C  OUTPUT:
      logical keof      !hit end of file
      integer ierr    !<>0, eof or some other error.
C
C  LOCAL:
C HISTORY:
! 2007Nov04  Modified to remove white space (" ", tabs) at front of a line.

! function
      integer trimlen

!     local
      logical kprint
      character*1024 ldum
      integer ilen
      integer ifirst_non_white
      integer nbeg,nend

C     0. INITIALIZE
C
      ierr = 0
      lstring= " "
      keof=.false.
      kprint=.false.

100   continue
      read(iunit,'(a1024)',err=500,end=600) ldum

      nend=trimlen(ldum)
      nbeg=ifirst_non_white(ldum)
      if(nbeg .ge. 1024) then
         lstring=" "
      else
         lstring=ldum(nbeg:)
      endif


      if(kprint) write(*,'(a)') lstring(1:40)
      if(imode .eq. 1) then
        if(lstring(1:1) .eq. "$") return
        goto 100
      else if(imode .eq. 2) then
        if(lstring(1:1) .eq. "*" .or. lstring.eq. " ") goto 100
!        if(lstring(1:1) .eq. "$") return
      else if(imode .eq. 3) then
        return
      else
        write(*,*) "Readline: Unknown mode: ", imode
      endif

500   continue
      ierr=1
      return
600   continue
      keof=.true.
      ierr=10
      return
      END
