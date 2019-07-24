      subroutine psetp(iwdsi,iwidxi,iwidyi)
C
C  SET Physical plot size 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      ichars=iwdsi*2
      iwidx=2*(iwidxi/2)
      iwidy=iwidyi
      if (iwidx*iwidy.gt.ichars) stop 1
C 
      return
      end 
