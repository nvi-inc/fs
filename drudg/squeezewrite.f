      subroutine squeezewrite(lufile,ldum)
      implicit none
! passed
      integer lufile
      character*(*) ldum
! local
      integer ilast_non_blank  !last non-blank

      call squeezeleft(ldum,ilast_non_blank)

      write(lufile,'(a)') ldum(1:ilast_non_blank)
      return
      end
