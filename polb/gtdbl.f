      double precision function gtdbl(jbuf,ifc,ilc,ifield,iferr)

      double precision das2b

      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      gtdbl=das2b(jbuf,ic1,ic2-ic1+1,jerr)
      if ((ic1.le.0.or.jerr.ne.0).and.iferr.ge.0) iferr=-ifield

      return
      end
