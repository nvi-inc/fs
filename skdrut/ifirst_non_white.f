      integer function ifirst_non_white(ldum)
      implicit none
! Find the first non  space or non-tab characer.
! History
!  2007Nov04 JMGipson.  First version

      character*(*) ldum
      integer i
      character*1 ltab
      ltab=char(9)    ! Tab character.

      do i=1,len(ldum)
        if(ldum(i:i) .ne. " ".and.ldum(i:i) .ne. ltab) then
           goto 100
        endif
      end do
100   continue
      ifirst_non_white=i
      return
      end
