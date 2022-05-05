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
      subroutine ExtractNextToken(lstring,istart,inext,ltoken,ktoken,
     >  knospace, keol)
      implicit none
! written

! History
!  2003Mar04    JMGipson First Version
!  2009Sep03    JMG. Modified to return as much of a token as possible. 
!               Previously, exited with error, but did not return token
     

! Given string specified by lstring, and starting point istart
! return token and next starting point.

! functions
      logical kwhitespace

! passed
      CHARACTER*(*) lstring
      INTEGER istart       	!place to start parsing
      Integer inext        	!end
! returned
      CHARACTER*(*) ltoken
      logical ktoken            !returned token?
      logical knospace          !no space left.
      logical keol              !end of line

! local
      INTEGER ilen,itoken_len
      integer ibeg

      ktoken=.false.
      knospace=.false.
      keol=.false.
      ilen=LEN(lstring)

! starting at istart, find first non-blank.
      do ibeg=istart,ilen,1
        if(.not. kwhiteSpace(lstring(ibeg:ibeg))) goto 100
      end do
      keol=.true.
      return

100   continue
      istart=ibeg
      itoken_len=Len(ltoken)

! now find next white space.
      do inext=ibeg,ilen
        if(kWhiteSpace(lstring(inext:inext))) goto 200
      end do
      keol=.true.

200   continue
      kNoSpace=itoken_len .lt. inext-ibeg
!      if(kNoSpace) return
      if(kNoSpace) then
          ltoken=lstring(ibeg:ibeg+itoken_len-1)
      else
        ltoken=lstring(ibeg:inext-1)
      endif
      ktoken=.true.
      return

      end
!**************************************************************
      logical function kwhitespace(lchar)

      character*1 lchar

      kwhitespace= lchar .eq. " " .or. lchar .eq. char(9)
      return
      end




