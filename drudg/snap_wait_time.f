      subroutine snap_wait_time(itimevec)
! write out wait command
      implicit none
      include 'hardware.ftni'
      integer itimevec(5)

      write(luFile,'("!",i4.4,".",i3.3,".",2(i2.2,":"),i2.2)')
     >  itimeVec(1:5)
      return
      end
