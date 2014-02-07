      subroutine copy_time(itime_from,itime_to)
      implicit none
      integer itime_from(5)   !time array to copy from
      integer itime_to(5)     !time array to copy to
! local
      integer i
      
      do i=1,5
         itime_to(i)=itime_from(i)
      end do
      return
      end
    
