      subroutine name_trkf(lnamep,lmode,lpmode,lpass)
      implicit none
!      include 'hardware.ftni'
      character*(*) lmode
      character*(*) lpmode
      character*1 lpass
      character*(*) lnamep
      integer ilast_non_blank

      write(lnamep,'("trkf",a,a,a1)') lmode,lpmode,lpass
!      call squeezewrite(lufile,ldum)
      call squeezeleft(lnamep,ilast_non_blank)
      end

