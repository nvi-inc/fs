      program drudg
      implicit none
      character*256 arg(7)
      integer i
c
      integer iargc
      external iargc
c
      do i=1,7
        if(i.gt.iargc()) then
           arg(i)=' '
        else
           call getarg(i,arg(i))
        endif
      enddo
      call fdrudg(arg(1),arg(2),arg(3),arg(4),arg(5),arg(6),arg(7))
C
      return
      end


