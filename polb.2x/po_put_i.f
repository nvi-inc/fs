      subroutine po_put_i(ibuf,nchar)
C
      integer*2 ibuf(1)
      integer nchar
c
      call fc_putln2(ibuf,nchar)
C
      return
      end
