      subroutine deerr(jbuf,ifc,ilc,off,wid,pk,bas,slp,rchi,iferr)
C 
      integer*2 jbuf(1)
C
      ifield=0
      iferr=1 
C 
C  OFFSET SIGMA 
C 
      off=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C HALF-WIDTH SIGMA
C 
      wid=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C FITTED PEAK SIGMA 
C 
      pk=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C  BASELINE TEMPERATURE SIGMA 
C 
      bas=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  BASELINE SLOPE SIGMA 
C 
      slp=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  REDUCED CHI OF THE FIT 
C 
      rchi=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
      return
      end 
