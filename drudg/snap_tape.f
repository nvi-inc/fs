      subroutine snap_tape(lstring)
!     JMGipson   2002Jan02  V1.00
      include 'hardware.ftni'
      character*(*) lstring

! Output "et" command.
      if(krec_append) then
        write(luFile,'("tape",a1,a)', err=100) crec(irec),lstring
      else
        write(luFile,'("tape",a)', err=100) lstring
      endif

      return
100   continue
      return
      end

