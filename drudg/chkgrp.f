      subroutine chkgrp (i1,itk,istart,istop,ihd,i2,itk2)
c check groups of tracks in itk from start to stop in 2s
c  if set and i1=0 then set i2=1
c.. if group set, zero the group in 2nd copy array itk2
      integer i1,i2,istart,istop
      integer itk(36,2), itk2(36,2)
      itest=1
      do i=istart,istop,2
        if( itk(i,ihd) .ne. 1 )itest=0
      enddo
      if ((itest .eq. 1) .and. (i1 .eq . 0)) then
        i2=1
        do i=istart,istop,2
          itk2(i,ihd)=0
        enddo
      else
        i2=0
      endif
      return
      end


