      subroutine incsm(luse,lonsum,lonrms,wlnsum,lnofr,wln,latsum,
     +                 latrms,wltsum,ltofr,wlt,dirms,wdisum,distr,
     +                 np,igp,feclon,feclat,coslt)
C
      double precision lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms
      double precision dim1,dri,ddisr,dwln,dwlt,wdisum,dwdi
      double precision dlnof,dltof
      real lnofr,ltofr,distr,coslt
      logical kbit
C
      if (.not.kbit(luse,np)) return
      igp=igp+1
      dlnof=dble(lnofr)
      dltof=dble(ltofr)
      ddisr=dble(distr)
      dwln=dble(wln*wln+sign(feclon*feclon,feclon))
      dwlt=dble(wlt*wlt+sign(feclat*feclat,feclat))
      dwdi=dwln*coslt*coslt+dwlt
      dwln=1.0d0/dwln
      dwlt=1.0d0/dwlt
      dwdi=1.0d0/dwdi
C
      lonsum=lonsum+dlnof*dwln
      latsum=latsum+dltof*dwlt
  
      lonrms=lonrms+(dlnof*dlnof)*dwln
      latrms=latrms+(dltof*dltof)*dwlt
      dirms= dirms+(distr*distr)*dwdi
C
      wlnsum=wlnsum+dwln
      wltsum=wltsum+dwlt
      wdisum=wdisum+dwdi
C
      return
      end
