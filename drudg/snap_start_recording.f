      subroutine snap_start_recording(kin2net) 
      include 'hardware.ftni'
      logical kin2net
! 2005Jul28  JMGipson.  Added "disk_record" after disk_record_on
! 2014Jan30  JMGipson. Removed disk crap. 
      
      if(km5disk) then
        if(kin2net) then
            write(lufile,'(a)') "in2net=on"
        else
           write(luFile,'("disk_record=on")')
           write(luFile,'("disk_record")')  
        endif
      endif 
      krunning=.true.           !turn on running flag.

      return
      end
