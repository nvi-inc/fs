      subroutine upper(ibuf,ifc,ilc)

      implicit none
      integer*2 ibuf(1)
      integer ifc,ilc
      integer nchar,i,ival,jchar
      character ch
 
      nchar = ilc - ifc + 1
      if (nchar.le.0) return
      do i=ifc,ilc
        ival=jchar(ibuf,i)
        if (ival.ge.97.and.ival.le.122) then
           ival = ival-32
           call pchar(ibuf,i,ival)
        endif
      enddo

      return
      end
