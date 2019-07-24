      subroutine pplpt(ibuf,x,y)
C
      integer*2 ibuf(1),iold
      integer jchar,ixy
C 
      real x,y
C
C  PLot PoinT 
C 
      call pv2ob(x,y,iox,ioy) 
      call po2pl(iox,ioy,ix,iy) 
      call pp2ch(ix,iy,ixy) 
C 
      iold=jchar(ibuf,ixy)
      idiff=0 
C 
      if (iold.eq.jchar(2H  ,1)) goto 50
      if (iold.eq.jchar(2H--,1)) goto 50
      if (iold.eq.jchar(2H||,1)) goto 50
C 
      idiff=iold-48 
      if (iold.ge.49.and.iold.le.57) goto 50
      idiff=iold-64+9 
      if (iold.ge.65.and.iold.le.90) goto 50
      stop 2
C
50    continue
      idiff=min0(idiff+1,35)
      inew=idiff+48
      if (inew.gt.57) inew=idiff-9+64
C
      idum=ichmv(ibuf,ixy,inew,1,1)
C
      return
      end
