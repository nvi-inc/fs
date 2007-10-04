      program drudg
      implicit none
      character*256 arg(7)
      integer i
c
c
      do i=1,7
           call getarg(i,arg(i))
      enddo
      call fdrudg(arg(1),arg(2),arg(3),arg(4),arg(5),arg(6),arg(7))
C
      end


