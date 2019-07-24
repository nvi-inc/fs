      subroutine pwipe(ibuf)
C
      integer*2 ibuf(1) 
C 
C  WIPE plotter clean 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      call ifill_ch(ibuf,1,ichars,' ')
C 
      return
      end 
