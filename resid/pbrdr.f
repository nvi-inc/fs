      subroutine pbrdr(ibuf)
C
      integer*2 ibuf(1) 
      integer*2 ipipe,idash

      data ipipe/2H||/
      data idash/2H--/
C 
C  draw BoRDeR
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      do i=iymin,iymax 
        call pppnt(ibuf,ixmin,i,ipipe) 
        call pppnt(ibuf,ixmax,i,ipipe) 
      enddo
C 
      do i=ixmin,ixmax 
        call pppnt(ibuf,i,iymin,idash) 
        call pppnt(ibuf,i,iymax,idash) 
      enddo
C 
      return
      end 
