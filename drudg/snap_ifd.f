      subroutine snap_ifd(lmode)
      include 'hardware.ftni'
      character*(*) lmode
      character*20 ldum

      write(ldum,'("ifd",a)') lmode
      call squeezewrite(lufile,ldum)
      end
