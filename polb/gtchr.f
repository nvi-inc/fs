      subroutine gtchr(lout,nf,nc,jbuf,ifc,ilc,ifield,iferr)
C
      integer*2 jbuf(1),lout(1)

      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ic1.le.0.and.iferr.ge.0) iferr=-ifield
      call ifill_ch(lout,nf,nc,' ')
      call ichmv(lout,nf,jbuf,ic1,min0(nc,ic2-ic1+1))
C
      return
      end
