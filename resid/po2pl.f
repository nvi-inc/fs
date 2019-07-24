      subroutine po2pl(iox,ioy,ix,iy) 
C 
C  convert Object 2 PLotter 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      ioxl=max0(1,min0(iox,ixmax-ixmin+1))
      ioyl=max0(1,min0(ioy,iymax-iymin+1))
C 
      ix=ioxl-1+ixmin 
      iy=ioyl-1+iymin 
C 
      return
      end 
