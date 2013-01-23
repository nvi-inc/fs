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




