      subroutine rstat(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,
     +                 dirms,wdisum,igp,lu)
C
      double precision lonsum,lonrms,latsum,latrms,dirms,wlnsum,wltsum
      double precision wdisum
      logical kif
C
      integer*2 lfat(13)
C
      data lfat/24,2hno,2h p,2hoi,2hnt,2hs ,2hfo,2hr ,2hst,2hat,
     /             2his,2hti,2hcs/
C          no points for statistics
C
      if (kif(lfat(2),lfat(1),idum,0,0,igp.le.0,lu)) stop
      didim1=0
      if (igp.gt.1) didim1=dble(float(igp))/dble(float(igp-1))
C
      lonsum=lonsum/wlnsum
      latsum=latsum/wltsum
C
      lonrms=lonrms/wlnsum
      latrms=latrms/wltsum
      dirms= dirms/wdisum
C
      lonrms=dsqrt(dabs(lonrms-lonsum*lonsum)*didim1)
      latrms=dsqrt(dabs(latrms-latsum*latsum)*didim1)
      dirms =dsqrt(dirms*didim1)
C
      return
      end
