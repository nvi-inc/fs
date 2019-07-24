      subroutine pppnt(ibuf,ix,iy,ic) 
C
      integer*2 ibuf(1),ic 
      integer*2 ichmv
C 
C  Put POiNT on plotter coordinates 
C 
      call pp2ch(ix,iy,ixy) 
      idum=ichmv(ibuf,ixy,ic,1,1) 
C
      return
      end 
