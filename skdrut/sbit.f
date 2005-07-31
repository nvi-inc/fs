      subroutine sbit(iarray,ibit,ival)
      implicit none
      integer iarray(*),ibit,ival
c
c   sbit sets (or resets) the ibit-th bit of iarray if ival is one
c   (or zero). sbit uses the same bit numbering convention as kbit.
c   values of ival other than 1 or 0 are no-ops.
c
c     include '../include/params.i'
C NRV 951015 set value of INT_BITS here
      integer INT_BITS
c
      integer ib,iw
! AEM undo     integer jibset,jibclr
! AEM 20050217 use ibset and ibclr instead of extension
      integer ibset,ibclr
c
      INT_BITS =32
      iw = ((ibit-1)/INT_BITS)+1
      ib = ibit - (iw-1)*INT_BITS
c
      if (ival.eq.1) then
! AEM undo         iarray(iw)=jibset(iarray(iw),ib-1)
         iarray(iw)=ibset(iarray(iw),ib-1)
      else if(ival.eq.0) then
! AEM undo         iarray(iw)=jibclr(iarray(iw),ib-1)
         iarray(iw)=ibclr(iarray(iw),ib-1)
      endif
c
      return
      end
