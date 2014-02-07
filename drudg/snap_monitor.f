      subroutine snap_monitor(kin2net)
      include 'hardware.ftni'
!  2014Jan31. Removed  tape based stuff. 

      logical kin2net

      if(Km5Disk) then
        if(kin2net) then
          write(luFile,'("in2net")')
        else
          write(luFile,'("disk_pos")')
        endif     
      endif

      return
      end
