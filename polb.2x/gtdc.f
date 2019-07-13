      real function gtdc(jbuf,ifc,ilc,ifield,iferr)
C
      double precision das2b
C
      include '../include/dpi.i'
C
      integer ichcm_ch
C
      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ichcm_ch(jbuf,ic1,'+').ne.0 .and.
     +   ichcm_ch(jbuf,ic1,'-').ne.0) ic1=ic1-1
      idd=ias2b(jbuf,ic1+1,2)
      idm=ias2b(jbuf,ic1+3,2)
      dcs=das2b(jbuf,ic1+5,ic2-(ic1+5)+1,jerr)
      ids=ias2b(jbuf,ic1+5,2)
      if ((ic1.le.0 .or.
     +   idd .eq. -32768 .or.
     +   idm .eq. -32768 .or.
     +   jerr.ne.      0 .or.
     +   (ic2.ne.ic1+6.and.ichcm_ch(jbuf,ic1+7,'.').ne.0)
     +   ) .and.iferr.ge.0) iferr=-ifield
      dec=float(idd)*1.0d0+float(idm)/60.0d0+
     +   dcs/3600.0d0
      if (ichcm_ch(jbuf,ic1,'-').eq.0) dec=-dec
      gtdc=dec*deg2rad

      return
      end
