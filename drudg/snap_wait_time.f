      subroutine snap_wait_time(luFile,itimevec)
! write out wait command
      implicit none
      integer itimevec(5)
      integer luFile

      write(luFile,'("!",i4.4,".",i3.3,".",2(i2.2,":"),i2.2)')
     >  itimeVec(1:5)
      return
      end
