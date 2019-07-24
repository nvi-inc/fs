      subroutine depr(jbuf,ifc,ilc,prlon,prlat,praz,prel,iferr) 
C
      integer*2 jbuf(1) 
C 
      ifield=0
      iferr=1 
C 
C  PREDICTED LONGITUDE LIKE COORDINATE
C 
      prlon=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C            LATITUDE LIKE COORDINATE 
C 
      prlat=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  PREDICTED AZIMUTH
C 
      praz=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C            ELEVATION
C 
      prel=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
      return
      end 
