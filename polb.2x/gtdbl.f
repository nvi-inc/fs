      double precision function gtdbl(jbuf,ifc,ilc,ifield,iferr)
C
      integer*2 jbuf(1)
C
      double precision das2b
C
      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if(ic1.le.0) then
        jerr=1
      else
        gtdbl=das2b(jbuf,ic1,ic2-ic1+1,jerr)
      endif
      if ((ic1.le.0.or.jerr.ne.0).and.iferr.ge.0) iferr=-ifield
C
      return
      end
