      subroutine name_trkf(itype,lmode,lpmode,lpass,lnamep)
      implicit none
!      include 'hardware.ftni'
! passed.
      integer itype
      character*(*) lmode
      character*(*) lpmode
      character*1 lpass
! returned
      character*(*) lnamep
      integer ilast_non_blank

      if(itype .gt. 1) then
        write(lnamep,'("trkf",a,a,a1)') lmode,lpmode,lpass
      else
        write(lnamep,'("trkf",a)') lmode
      endif
!     call squeezewrite(lufile,ldum)
      call squeezeleft(lnamep,ilast_non_blank)
      end

