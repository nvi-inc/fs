      subroutine snap_recp(lmode)
      include 'hardware.ftni'
      character*(*) lmode
      character*20 ldum

      write(ldum,'("recp",a)') lmode
      call squeezewrite(lufile,ldum)

      return
      end

