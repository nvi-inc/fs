      subroutine lower(ibuf,nchar)
      implicit none
      integer*2 ibuf(1)
      integer nchar
c
c  convert hollerith to lower case
c  this routine has the wrong calling sequence! it's missing the
c     character to start at
c
      integer i,ival,jchar
c
      if (nchar.le.0) return
      do i=1,nchar
        ival=jchar(ibuf,i)
        if(ival.ge.65.and.ival.le.90) then
           ival=ival+32
           call pchar(ibuf,i,ival)
        endif
      enddo
c
      return
      end
