      real function gtra(jbuf,ifc,ilc,ifield,iferr)
C
      double precision das2b
C
      include '../include/dpi.i'
C
      integer ichcm_ch
C
      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      irh=ias2b(jbuf,ic1,2)
      irm=ias2b(jbuf,ic1+2,2)
      ras=das2b(jbuf,ic1+4,ic2-(ic1+4)+1,jerr)
      if ((ic1.le.0 .or.
     +   irh .eq. -32768 .or.
     +   irm .eq. -32768 .or.
     +   irs .eq. -32768 .or.
     +   jerr.ne.      0 .or.
     +   (ic2 .ne. ic1+5  .and. ichcm_ch(jbuf,ic1+6,'.').ne.0)
     +   ) .and.iferr.ge.0) iferr=-ifield
      ra=float(irh)*3600.d0+float(irm)*60.d0+
     +   ras*1.0d0
      gtra=ra*sec2rad

      return
      end
