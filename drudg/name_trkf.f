      subroutine name_trkf(lmode,lpmode,lpass,lnamep)
      include 'hardware.ftni'
! passed.
      character*(*) lmode
      character*(*) lpmode
      character*1 lpass
! returned
      character*(*) lnamep
      integer ilast_non_blank

! 2015Jun05. Removed commented out code. 

      if(knopass) then
        write(lnamep,'("trkf",a)') lmode
      else
        write(lnamep,'("trkf",a,a,a1)') lmode,lpmode,lpass
      endif
      call squeezeleft(lnamep,ilast_non_blank)
      end

