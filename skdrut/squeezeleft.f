      subroutine squeezeleft(lstring,ilast_non_blank)
! remove blank space.
      implicit none
      character*(*) lstring
      integer ilast_non_blank
! local
      integer ilen
      integer i
      integer iptr
      ilen=len(lstring)

      iptr=1
      do i=1,ilen
        if(lstring(i:i) .ne. " ") then
           lstring(iptr:iptr)=lstring(i:i)
           iptr=iptr+1
        endif
      end do
      if(iptr .le. ilen) then
         lstring(iptr:ilen) = " "       !put spaces at the end.
      endif
      ilast_non_blank=iptr-1
      return
      end






