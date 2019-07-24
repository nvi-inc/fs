      subroutine defit(jbuf,ifc,ilc,off,wid,pk,bas,slp,ifcod,iferr) 
C
      integer*2 jbuf(1)
C 
      ifield=0
      iferr=1 
C 
C OFFSET
C 
      off=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C HALF-WIDTH
C 
      wid=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C FITTED PEAK 
C 
      pk=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C BASE LINE TEMP
C 
      bas=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  BASE LINE SLOPE
C 
      slp=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C FIT CODE
C 
      ifcod=igtbn(jbuf,ifc,ilc,ifield,iferr)
C 
      return
      end 
