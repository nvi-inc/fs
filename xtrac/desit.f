      subroutine desit(jbuf,ifc,ilc,lant,slon,slat,adiam,lsaxis,
     +                 imodel,fpver,fsver,iferr)
C
      integer*2 jbuf(1),lant(1),lsaxis(1)
C 
      ifield=0
      iferr=1 
C 
C SITE ANTENNA
C 
      call gtchr(lant,1,8,jbuf,ifc,ilc,ifield,iferr)
C 
C LONGTUDE
C 
      slon=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C LATITIUDE 
C 
      slat=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C ADIAM 
C 
      adiam=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C AXIS TYPE 
C 
      call gtchr(lsaxis,1,4,jbuf,ifc,ilc,ifield,iferr)
C 
C MODEL NUMBER
C 
      imodel=igtbn(jbuf,ifc,ilc,ifield,iferr) 
C 
C FIVPT VERSION 
C 
      fpver=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C FS VERSION
C 
      fsver=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
      return
      end 
