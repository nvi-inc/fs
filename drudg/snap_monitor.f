      subroutine snap_monitor
      include 'hardware.ftni'

      if(km5) then
        write(luFile,'(a)') 'disc_pos'
        if(km5_piggyback)   write(luFile,'(a)') 'disc_pos'
      else
        if(krec_append) then
          write(luFile,'("tape",a1)') crec(irec)
        else
          writE(luFile,'("tape")')
        endif
      endif
      return
      end
