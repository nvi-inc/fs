      subroutine snap_pcalf(lmode)
      include 'hardware.ftni'
      character*(*) lmode
      character*20 ldum
! 2015Jun05 JMG. Repalced squeezewrite by drudg_write. 
      write(ldum,'("pcalf",a)') lmode
      call drudg_write(luFile,ldum)

      return
      end

