      subroutine snap_monitor(kin2net)
      include 'hardware.ftni'

      logical kin2net

      if(Km5Disk) then
        if(kin2net) then
          write(luFile,'("in2net")')
        else
          write(luFile,'("disk_pos")')
        endif
      else
        if(krec_append) then
          write(luFile,'("tape",a1)') crec(irec)
        else
          writE(luFile,'("tape")')
        endif
        if(km5P_piggy .or. km5A_piggy) write(luFile,'("disk_pos")')
      endif

      return
      end
