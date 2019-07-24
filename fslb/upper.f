      subroutine upper(ibuf,ifc,ilc)

      implicit none
      integer*2 ibuf(1)
      integer ifc,ilc
      integer nchar,i,ival
      character ch
 
      nchar = ilc - ifc + 1
      if (nchar.le.0) return
      do i=ifc,ilc
        call hol2char(ibuf,i,i,ch)
        ival=ichar(ch)
        if (ival.ge.97.and.ival.le.122) ch = char(ival-32)
        call char2hol(ch,ibuf,i,i)
      enddo

      return
      end
