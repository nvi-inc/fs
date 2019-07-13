      subroutine po_put_c(string)

      character*(*) string
      integer nchar, trimlen
 
      nchar=trimlen(string)
      write(6,9100) string(:nchar)
9100  format(1x,a)

      return
      end
