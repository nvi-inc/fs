      subroutine snap_pcalf(lmode)
      include 'hardware.ftni'
      character*(*) lmode
      character*20 ldum

      write(ldum,'("pcalf",a)') lmode
      call squeezewrite(luFile,ldum)

      return
      end

