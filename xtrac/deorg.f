      subroutine deorg(jbuf,ifc,ilc,haoff,decoff,azoff,eloff,xoff,yoff, 
     +                 iferr) 
C
      integer*2 jbuf(1) 
C 
      ifield=0
      iferr=1 
C 
C HA OFFSET 
C 
      haoff=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C DEC 
C 
      decoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C AZIMUTH 
C 
      azoff=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C ELEVATION 
C 
      eloff=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C X 
C 
      xoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C Y 
C 
      yoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
      return
      end 
