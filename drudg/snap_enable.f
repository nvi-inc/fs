      subroutine snap_enable()
!     JMGipson   2002Jan02  V1.00
      include 'hardware.ftni'

      if(krec_append) then
        write(luFile,'("enable",a1,"=")', err=100) crec(irec)
      else
        write(luFile,'("enable=")', err=100)
      endif

      return
100   continue
      return
      end

