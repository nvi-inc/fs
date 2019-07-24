      subroutine pp2ch(ix,iy,ixy) 
C 
C  convert Plotter units 2 CHaracter number 
  
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      ixl=max0(1,min0(ix,iwidx))
      iyl=max0(1,min0(iwidy-iy+1,iwidy))
C 
      ixy=ixl+(iyl-1)*iwidx 
C 
      return
      end 
