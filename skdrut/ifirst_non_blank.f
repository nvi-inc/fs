      integer function ifirst_non_blank(ldum)
      implicit none
      character*(*) ldum
      integer i

      do i=1,len(ldum)
        if(ldum(i:i) .ne. " ") then
           goto 100
        endif
      end do
100   continue
      ifirst_non_blank=i
      return
      end
