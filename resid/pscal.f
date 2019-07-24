      subroutine pscal(x,npts,xmin,xmax)
C
      real x(npts), xmin, xmax 
C 
      xmin=0.0
      xmax=0.0
C 
      if (npts.le.0) return
C 
      xmin=x(1) 
      xmax=x(1) 
C 
      do i=1,npts
        if (x(i).lt.xmin) xmin=x(i)
        if (x(i).gt.xmax) xmax=x(i)
      enddo
C
      return
      end
