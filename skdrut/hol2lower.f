      subroutine hol2lower(iarr,ilen)
      implicit none
c
c Convert any upper case to lower.
C 930601 NRV Input is hollerith. In this routine, change to a
C            string, convert, then change back.
C 960213 nrv Make local string bigger
c
C Input:
      integer*2 iarr(*)!NOTE: iarr is modified upon return
      integer ilen ! length in characters
C Local:
      integer i,ival
C ***********NOTE*********** change this when ibuf is changed
      character*1024 string
c
      call hol2char(iarr,1,ilen,string)
      do i=1,ilen
        ival=ichar(string(i:i))
        if(ival.ge.65.and.ival.le.90) string(i:i)=char(ival+32)
      enddo
      call char2hol(string,iarr,1,ilen)
c
      return
      end

