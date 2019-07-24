      subroutine deoff(jbuf,ifc,ilc,loncor,latcor,lonoff,latoff,iqlon,
     +                 iqlat,iferr) 
C
      integer*2 jbuf(1) 
C
      real loncor,latcor,lonoff,latoff
C 
      iferr=1 
      ifield=0
C 
C  LONGITUDE LIKE COORDINATE
C 
      loncor=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C LATITUDE LIKE COORDIANE 
C 
      latcor=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C  LONGITUDE LIKE COORDIATE OFFSET
C 
      lonoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C LATITUDE LIKE COORDIANTE OFFSET 
C 
      latoff=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C LONGITUDE FIT QUALITY BIT 
C 
      iqlon=igtbn(jbuf,ifc,ilc,ifield,iferr)
C 
C LATITUDE FIT QUALITY BIT
C 
      iqlat=igtbn(jbuf,ifc,ilc,ifield,iferr)
C 
      return
      end 
