      subroutine snap_wait_sec(iseconds)
!     JMGipson   2002Jan02  V1.00
      implicit none
      include 'hardware.ftni'
      integer iseconds

! issue wait command.
      if(iseconds .lt. 10) then
        write(luFile,'("!+",i1,"s")') iseconds
      else if(iseconds .lt. 100) then
        write(luFile,'("!+",i2,"s")') iseconds
      else
        write(*,*) "Wait too long!"
      endif
      return
      end
