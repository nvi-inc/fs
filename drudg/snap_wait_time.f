      subroutine snap_wait_time(luFile,itimevec)
! write out wait command
      implicit none
! passed
      integer itimevec(5)
      integer luFile
! local
      integer i

      integer itime_save(5)
      common /time_save/itime_save

      do i=1,5
        itime_save(i)=itimevec(I)
      end do


      write(luFile,'("!",i4.4,".",i3.3,".",2(i2.2,":"),i2.2)')
     >  itimeVec(1:5)
      return
      end
!************************************************************
      subroutine snap_last_wait_time(itimeout)
      implicit none
      integer itimeout(5)
      integer i
! return last wait time.
      integer itime_save(5)
      common /time_save/itime_save

      do i=1,5
         itimeout(i)=itime_save(i)
      end do
      return
      end



