      subroutine snap_in2net_connect(lu,ldestin,loptions)
      implicit none
! passed
      integer lu
      character*(*) ldestin     !destionation
      character*(*) loptions    !options
! funcionts
      integer trimlen


! local
      integer nch2,nch3
      character*200 ldum

      nch2=trimlen(ldestin)
      if(nch2 .eq. 0) nch2=1
      nch3=trimlen(loptions)
      if(nch3.eq. 0) nch3=1
      write(ldum,"('in2net=connect,',a,',',a)")
     >  ldestin(1:nch2),loptions(1:nch3)
      call squeezewrite(lu,ldum)       !get rid of spaces, and write it out.
      return
      end
