      subroutine snap_rw()
!     JMGipson   2002Jan02  V1.00
      include 'hardware.ftni'
! Output "et" command.

      if(krec_append) then
        write(luFile,'("rw",a1)', err=100) crec(irec)
      else
        write(luFile,'("rw")', err=100)
      endif

      return
100   continue
      return
      end

