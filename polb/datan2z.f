      double precision function datan2z(x,y)
      implicit none
      double precision x,y
C
      if (x.eq.0.0d0.and.y.eq.0.0d0) then
        datan2z=0.0d0
      else
        datan2z=datan2(x,y)
      endif
C
      return
      end
