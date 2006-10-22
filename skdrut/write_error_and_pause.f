      subroutine write_error_and_pause(lu_out,lstring)
! do as the name suggests.
      integer lu_out
      character*(*) lstring

! function
      integer trimlen
! local
      integer nch
      character*1 lchar

      nch=max(trimlen(lstring),1)

      write(lu_out,*) "ERROR:  ",lstring(1:nch)
      write(*,*) "Type <RET> to continue."
      read(*,'(a)') lchar

      return
      end
