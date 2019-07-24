      subroutine char2low(cbuf)

      implicit none
      character*(*) cbuf
      integer i,ival
      character ch
 
      if (len(cbuf).le.0) return
      do i=1,len(cbuf)
        ch = cbuf(i:i)
        ival=ichar(ch)
        if(ival.ge.65.and.ival.le.90) ch = char(ival+32)
        cbuf(i:i) = ch
      enddo

      return
      end
