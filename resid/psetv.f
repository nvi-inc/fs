      subroutine psetv(xmini,xmaxi,ymini,ymaxi)
C
      real xmini, xmaxi, ymini, ymaxi
C
C  SET Virtual window limits (data units window limits) 
C 
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax, 
     +             xmin,xmax,ymin,ymax, 
     +             rotat(2,2) 
C 
      xmin=xmini
      ymin=ymini
      xmax=xmaxi
      ymax=ymaxi
C 
      return
      end 
