      subroutine snap_data_valid(lstring)
!     JMGipson   2002Jan02  V1.00
      include 'hardware.ftni'
      character*(*) lstring

! Output "et" command.
      if(krec_append) then
        write(luFile,'("data_valid",a1,a)', err=100) crec(irec),lstring
      else
        write(luFile,'("data_valid",a)', err=100) lstring
      endif

      return
100   continue
      return
      end

