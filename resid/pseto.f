      subroutine pseto(ixmini,ixmaxi,iymini,iymaxi)
C
C  SET Object window limits (plotter units window limits) 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      ixmin=ixmini
      iymin=iymini
      ixmax=ixmaxi
      iymax=iymaxi
C
      return
      end 
