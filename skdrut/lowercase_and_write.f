      subroutine lowercase_and_write(lu_out,cbuf)
      character*(*) cbuf
      integer lu_out
! function
      integer trimlen
! local
      integer nch
      nch=trimlen(cbuf)

      call lowercase(cbuf(1:nch))
      write(lu_out,'(a)') cbuf(1:nch)
      return
      end

