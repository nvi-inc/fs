      subroutine snap_rollform(lmode)
      include 'hardware.ftni'
      character*(*) lmode
      character*20 ldum

      write(ldum,'("rollform",a)') lmode
      call squeezewrite(luFile,ldum)
      return
      end

