      subroutine pv2ob(x,y,iox,ioy) 
C 
      real x,y
C  convert Virtual 2 OBject 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      xl=amax1(xmin,amin1(x,xmax))
      yl=amax1(ymin,amin1(y,ymax))
C 
      xratio=(xl-xmin)/(xmax-xmin)-0.5
      yratio=(yl-ymin)/(ymax-ymin)-0.5
C 
      xrot=rotat(1,1)*xratio+rotat(1,2)*yratio+0.5
      yrot=rotat(2,1)*xratio+rotat(2,2)*yratio+0.5
C 
      iox=xrot*float(ixmax-ixmin)+1.5 
      ioy=yrot*float(iymax-iymin)+1.5 
C 
      return
      end 
