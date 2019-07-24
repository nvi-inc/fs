      subroutine incsm(lonsum,lonrms,lnofr,latsum,latrms,ltofr,
     +                 dirms,distr,np,lut)
C
      double precision lonsum,lonrms,latsum,latrms,dirms
      double precision dim1,dri,dlnof,dltof,ddisr
      real lnofr,ltofr,distr
C
      dim1=dble(float(np-1)/float(np))
      dri=1.0d0/dble(float(np))
      dlnof=dble(lnofr)
      dltof=dble(ltofr)
      ddisr=dble(distr)
      lonsum=lonsum*dim1+dlnof*dri
      latsum=latsum*dim1+dltof*dri
      lonrms=lonrms*dim1+dlnof*dlnof*dri
      latrms=latrms*dim1+dltof*dltof*dri
      dirms=dirms*dim1+ddisr*ddisr*dri
C
      return
      end
