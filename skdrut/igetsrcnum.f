      integer FUNCTION IGetsrcNum(lsrc)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'

!      integer iwhere_in_string_list
      integer iStringMinMatch
C     CHECK THROUGH LIST OF SOURCES FOR A MATCH WITH LKEYWD
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
C     ALSO MAY HAVE A SOURCE INDEX NUMBER ALLOWED.
C 970114 nrv Change 4 to max_sorlen/2
C 970406 nrv Minimum matching
!     JMGipson. Changed to do minimum matching
      character*(*) lsrc
      integer i2ndmatch
      integer itemp
      integer ilen2

! first, see if we can read a number.
      read(lsrc,*,err=100) igetSrcNum
      if(igetSrcNum .gt. Nsourc) goto 100  !If a big number, assume start of source name.
      return

! not a number. Must be a source name. Look it up in the list.
100   continue
      i2ndMatch=0
      igetSrcNum=iStringMinMatch(csorna,Nsourc,lsrc)

      if(igetSrcNum .gt. 0 .and. igetSrcNum .lt. Nsourc) then
         itemp=igetSrcNum+1
         ilen2=Nsourc-igetSrcNum
         i2ndMatch=iStringMinMatch(csorna(itemp),ilen2,lsrc)
         if(i2ndMatch .gt. 0) igetSrcNum=-1
      endif
      RETURN
      END
