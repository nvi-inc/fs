      subroutine snap_disc_end
      include 'hardware.ftni'

      write(luFile,'(a)') 'disc_end'
      if(km5A_piggy .or. km5P_piggy)   write(luFile,'(a)') 'disc_end'
      return
      end
