      subroutine snap_monitor
      include 'hardware.ftni'

      if(km5) then
        write(luFile,'("disc_pos")')
      else
        if(krec_append) then
          write(luFile,'("tape",a1)') crec(irec)
        else
          writE(luFile,'("tape")')
        endif
      endif
      if(km5P_piggy .or. km5A_piggy)  write(luFile,'("disc_pos")')
      return
      end
