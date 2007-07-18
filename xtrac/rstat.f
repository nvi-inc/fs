      subroutine rstat(lonsum,lonrms,latsum,latrms,dirms,igp,lu)
C
      double precision lonsum,lonrms,latsum,latrms,dirms
      integer igp,lu
      logical kif,kigp
      double precision didim1
C
      integer*2 lfat(16)
C
      data lfat/29,2hfa,2hta,2hl ,2hin,2hte,2hrn,2hal,2h e,2hrr,
     /             2hor,2h i,2hn ,2hrs,2hta,2ht /
C          fatal internal error in rstat
C
      kigp = igp.le.0
      if (kif(lfat(2),lfat(1),idum,0,0,kigp,lu)) stop
      didim1=0
      if (igp.gt.1) didim1=dble(float(igp))/dble(float(igp-1))
C
      lonrms=dsqrt(dabs(lonrms-lonsum*lonsum)*didim1)
      latrms=dsqrt(dabs(latrms-latsum*latsum)*didim1)
      dirms=dsqrt(dirms)
C
      return
      end
