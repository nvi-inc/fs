      subroutine snap_recp(lmode)
      include 'hardware.ftni'
      character*(*) lmode
      character*20 ldum
! 2015Jun05 JMG. Repalced squeezewrite by drudg_write. 
      write(ldum,'("recp",a)') lmode
      call drudg_write(lufile,ldum)

      return
      end

