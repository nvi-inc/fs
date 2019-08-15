      subroutine snap_in2net_connect(lu,ldestin,loptions)
      implicit none
! passed
      integer lu
      character*(*) ldestin     !destionation
      character*(*) loptions    !options
! funcionts
      integer trimlen
! 2015Jun05 JMG. Repalced squeezewrite by drudg_write. 

! local
      integer nch2,nch3
      character*200 ldum
      if(ldestin .eq. " ") return

      nch2=trimlen(ldestin)
      if(nch2 .eq. 0) nch2=1
      nch3=trimlen(loptions)
      if(nch3.eq. 0) nch3=1
      write(ldum,"('in2net=connect,',a,',',a)")
     >  ldestin(1:nch2),loptions(1:nch3)
      call drudg_write(lu,ldum)       !get rid of spaces, and write it out.
      return
      end
