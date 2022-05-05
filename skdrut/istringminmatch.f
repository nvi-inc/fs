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
      integer function iStringMinMatch(list,ilen,ltest)

! functions
      integer trimlen
! on entry
      character*(*) ltest       !we try to find a match here
      integer ilen              !number we match against
      character*(*) list(ilen)   !string vector
! list is what we match against.
! local
      integer nch
      character*80 ltemp,ltemp2
      integer i
      integer iwidth

      nch=trimlen(ltest)        !number of non-blanks.
      ltemp=" "
      ltemp(1:nch)=ltest
      call squeezeleft(ltemp,nch)   !get rid of spaces at front.

      iwidth=len(list(1))         !input string can't match list, because too long!
      if(iwidth .lt. nch) then
        istringMinMatch=0
        return
      endif

      call capitalize(ltemp)

      do iStringMinMatch=1,ilen
        ltemp2=list(istringMinMatch)
        call capitalize(ltemp2)
        if(ltemp(1:nch).eq.ltemp2(1:nch)) goto 100
      end do
      iStringMinMatch=0
      return    !Return with no match.

100   continue
      do i=iStringMinMatch+1,ilen
        ltemp2=list(i)
        call capitalize(ltemp2)
        if(ltemp(1:nch) .eq. ltemp2(1:nch)) then
          iStringMinMatch=-1
          return
        endif
      end do

! found only 1 match. Return.
      return
      end
