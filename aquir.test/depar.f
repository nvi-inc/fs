      subroutine depar(jbuf,ifc,ilc,lset,iwset,lter,iwter,elmax,
     +                 mprc,iferr,isrcwt,isrcld)
C
      include '../include/dpi.i'
C
      integer*2 jbuf(1),lset(mprc),lter(mprc)
C
C
      iferr=1
      ifield=0
C
C Setup procedure
C
      call gtchr(lset,1,mprc*2,jbuf,ifc,ilc,ifield,iferr)
C
C Setup procedure wait
C
      iwset=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C Termination procedure
C
      call gtchr(lter,1,mprc*2,jbuf,ifc,ilc,ifield,iferr)
C
C Termination procedure wait
C
      iwter=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C maximum Elevation
C
      elmax=gtrel(jbuf,ifc,ilc,ifield,iferr)*RPI/180.
C
C source wait
C
      isrcwt=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C source lead time
C
      isrcld=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
      return
      end
