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
      character*80 ltemp
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
        if(ltemp(1:nch).eq.list(iStringMinMatch)(1:nch)) goto 100
      end do
      iStringMinMatch=0
      return    !Return with no match.

100   continue
      do i=iStringMinMatch+1,ilen
        if(ltemp(1:nch) .eq. list(i)(1:nch)) then
          iStringMinMatch=-1
          return
        endif
      end do

! found only 1 match. Return.
      return
      end
