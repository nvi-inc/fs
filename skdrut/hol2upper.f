      subroutine hol2upper(iarr,ilen)
      implicit none
c
c Convert any lower case to upper.
C 930601 NRV Input is hollerith. In this routine, change to a
C            string, convert, then change back.
C 960213 nrv Make local string bigger
c
C Input:
      integer*2 iarr(*)
      integer ilen !NOTE: iarr is modified upon return
C Local:
      integer i,ival
C*************NOTE************ change this when ibuf is changed!
      character*1024 string
c
      call hol2char(iarr,1,ilen,string)
      do i=1,ilen
        ival=ichar(string(i:i))
        if(ival.gt.96.and.ival.lt.123) string(i:i)=char(ival-32)
      enddo
      call char2hol(string,iarr,1,ilen)
c
      return
      end

