      subroutine snap_disc_end
      include 'hardware.ftni'
      write(luFile,'(a)') 'disc_end'
      if(km5_piggyback)   write(luFile,'(a)') 'disc_end'
      return
      end
