      subroutine detsy(jbuf,ifc,ilc,tsaz,tsel,tsys,iferr)
C
      integer*2 jbuf(1)
C
      ifield=0
      iferr=1
C
      tsaz=gtrel(jbuf,ifc,ilc,ifield,iferr)
C
      tsel=gtrel(jbuf,ifc,ilc,ifield,iferr)
C
      tsys=gtrel(jbuf,ifc,ilc,ifield,iferr)
C
      return
      end
