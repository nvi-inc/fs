      subroutine snap_monitor
      include 'hardware.ftni'

      if(km5A.or.KM5P) then
        write(luFile,'("disc_pos")')
      else
        if(krec_append) then
          write(luFile,'("tape",a1)') crec(irec)
        else
          writE(luFile,'("tape")')
        endif
        if(km5P_piggy .or. km5A_piggy) write(luFile,'("disc_pos")')
      endif

      return
      end
