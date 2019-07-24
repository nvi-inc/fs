      subroutine demas(jbuf,ifc,ilc,azar,elar,imask,imsmax,iferr)
C
      real azar(1),elar(1)
      integer*2 jbuf(1)
C
      include '../include/dpi.i'
C
      iferr=1
      ifield=0
C
C AZIMUTH
C
      i=-imask
1     continue
      i=i+1
      az=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      if (iferr.lt.0) then
        iferr=0
        imask=1-i
        return
      else if (i.gt.imsmax) then
        call putcon_ch('too many elevation mask azimuths')
        stop
      endif
      azar(i)=az
C
C Elevation
C
      elar(i)=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      if (iferr.lt.0.and.i.lt.2) then
        call putcon_ch('minimum of two azimuths in elevation mask')
        stop
      else if (iferr.lt.0) then
        iferr=-iferr
        imask=i
        return
      endif
      goto 1
C
      return
      end
