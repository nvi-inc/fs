      subroutine ifill4(iarray,Ilen,ivalue)
!passed
      integer ilen
      integer iarray(ilen)
      integer ivalue
! local
      integer i
      do i=1,ilen
        iarray(i)=ivalue
      end do
      return
      end
