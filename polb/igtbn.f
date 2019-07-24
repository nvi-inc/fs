      integer function igtbn(jbuf,ifc,ilc,ifield,iferr)

      integer*2 jbuf(1)

      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      igtbn=ias2b(jbuf,ic1,ic2-ic1+1)
      if ((ic1.le.0.or.igtbn.eq.-32768).and.iferr.ge.0) iferr=-ifield

      return
      end
