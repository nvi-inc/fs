      subroutine psetr(rotati) 
      dimension rotati(2,2) 
C 
C  SET virtual window rotation matrix 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      rotat(1,1)=rotati(1,1)
      rotat(2,1)=rotati(2,1)
      rotat(1,2)=rotati(1,2)
      rotat(2,2)=rotati(2,2)
C
      return
      end 
