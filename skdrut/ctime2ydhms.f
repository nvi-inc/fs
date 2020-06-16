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
      subroutine ctime2YDhms(ctime,iyear,iday,ihour,imin,isec,ierr)
! Convert an ascii string to iyear, idoy, ihour,imin,isec
      implicit none  !2020Jun15 JMGipson automatically inserted.
! All dashes, spaces and colons are stripped out.
! Remaining string must be set number of characters long
! Valid formats are:
!
!  2004-271-18:30:40
!  2004271183040
!  YYYYDDDHHMMSS   13
!  YYDDDDHHMMSS    11
!  DDDHHMMSS        9         Use input year.
!  HHMMSS           6         Use input year and DOY.
!  ^                1         before start of experiment,
!  .                1         Return with no action.
!  *                1         after end of experiment.
! History
!  V1.00 2005Feb17  JMGipson. First version.
!  V1.01 2005Mar30  JMGipson. Modified to also parse 9 and 6 character strings,
!                   as well as single characrters: "^", ".", "*"

! Input
      character*(*) ctime
      character*13 ctemp
! output
      integer iyear,iday,ihour,imin,isec,ierr
! functions
      integer trimlen
! local
      integer nch,iptr,i

      ctemp=" "

      nch=trimlen(ctime)
      iptr=0
      do i=1,nch
        if(ctime(i:i) .ne. " " .and. ctime(i:i) .ne. "-" .and.
     >     ctime(i:i) .ne. ":") then
          iptr=iptr+1
          if(iptr .gt. 13) goto 900       !out of space.
          ctemp(iptr:iptr)=ctime(i:i)
        endif
      end do

      nch=trimlen(ctemp)
      if(nch .eq. 1) then
        if(ctemp(1:1) .eq. ".") return
        ihour=0
        imin=0
        isec=0
        if(ctemp(1:1) .eq. "*") then
          iday=366
          iyear=2099
          return
        else if(ctemp(1:1) .eq. "^") then
          iday=1
          iyear=1900
          return
        else
           goto 900
        endif
      else if(nch .eq. 6) then
        read(ctemp,'(3(i2))',err=900)  ihour,imin,isec
      else if(nch .eq. 9) then
        read(ctemp,'(i3,3(i2))',err=900)  iday,ihour,imin,isec
      else if(nch .eq. 11) then
        read(ctemp,'(i2, i3,3(i2))',err=900) iyear,iday,ihour,imin,isec
        if(iyear .gt. 70) then
           iyear=iyear+1900
        else
           iyear=iyear+2000
        endif
      else if(nch .eq. 13) then
        read(ctemp,'(i4, i3,3(i2))',err=900) iyear,iday,ihour,imin,isec
      else
        goto 900
      endif
      ierr=0
      return

900   continue
      ierr=1
      write(*,*) "Ctime2YDHMS error: Can't parse ",ctime
      return
      end
