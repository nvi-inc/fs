      subroutine po_put_i(ibuf,nchar)
C
      integer*2 ibuf(1)
      integer nchar
c
      write(6,'(1x,256a2)') (ibuf(i),i=1,nchar/2)
C
      return
      end
