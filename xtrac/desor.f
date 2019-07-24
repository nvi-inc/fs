      subroutine desor(jbuf,ifc,ilc,lsorna,ra,dec,epoch,iyr,idoy,ihr, 
     +                 im,is,iferr) 
C
      integer*2 jbuf(1),lsorna(1)
      integer ichcm_ch
C 
      iferr=1 
      ifield=0
C 
C SOURCE NAME 
C 
      call gtchr(lsorna,1,10,jbuf,ifc,ilc,ifield,iferr) 
C 
C  RA 
C 
      ifield=ifield+1 
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      irh=ias2b(jbuf,ic1,2) 
      irm=ias2b(jbuf,ic1+2,2) 
      irs=ias2b(jbuf,ic1+4,2) 
      irts=ias2b(jbuf,ic1+7,1)
      if ((ic1.le.0 .or. 
     +   irh .eq. -32768 .or. 
     +   irm .eq. -32768 .or. 
     +   irs .eq. -32768 .or. 
     +   irts.eq. -32768 .or. 
     +   ichcm_ch(jbuf,ic1+6,'.').ne.0).and.iferr.ge.0) iferr=-ifield 
      ra=float(irh)*15.0+float(irm)/4.0+
     +   float(irs)/240.0+float(irts)/2400.0
C 
C DEC 
C 
      ifield=ifield+1 
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ichcm_ch(jbuf,ic1,'+').ne.0 .and.
     +   ichcm_ch(jbuf,ic1,'-').ne.0) ic1=ic1-1 
      idd=ias2b(jbuf,ic1+1,2) 
      idm=ias2b(jbuf,ic1+3,2) 
      ids=ias2b(jbuf,ic1+5,2) 
      if ((ic1.le.0 .or. 
     +   idd .eq. -32768 .or. 
     +   idm .eq. -32768 .or. 
     +   ids .eq. -32768) .and.iferr.ge.0) iferr=-ifield
      dec=float(idd)+float(idm)/60.0+ 
     +   float(ids)/3600.0
      if (ichcm_ch(jbuf,ic1,'-').eq.0) dec=-dec
C 
C  EPOCH
C 
      epoch=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C DATE AND TIME 
C 
      ifield=ifield+1 
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      iyr=ias2b(jbuf,ic1,2) 
      idoy=ias2b(jbuf,ic1+3,3)
      ihr=ias2b(jbuf,ic1+7,2) 
      im=ias2b(jbuf,ic1+10,2) 
      is=ias2b(jbuf,ic1+13,2) 
      if ((ic1.le.0.or.
     +   iyr   .eq.-32768 .or.
     +   idoy  .eq.-32768 .or.
     +   ihr   .eq.-32768 .or.
     +   im    .eq.-32768 .or.
     +   is    .eq.-32768) .and. iferr.ge.0) iferr=-ifield
C 
      return
      end 
