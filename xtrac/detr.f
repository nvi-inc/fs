      subroutine detr(jbuf,ifc,ilc,iayr,iadoy,iahr,iam,ias,iats,
     +                anlon,anlat,erlon,erlat,iferr)
C
      integer*2 jbuf(1) 
C 
      ifield=0
      iferr=1 
C 
C POINTING COMPUTER TIME
C 
      ifield=ifield+1 
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      iayr=ias2b(jbuf,ic1,2)
      iadoy=ias2b(jbuf,ic1+3,3) 
      iahr=ias2b(jbuf,ic1+7,2)
      iam=ias2b(jbuf,ic1+10,2)
      ias=ias2b(jbuf,ic1+13,2)
      iats=ias2b(jbuf,ic1+16,1) 
      if ((ic1.le.0 .or. 
     +   iayr .eq.-32768 .or. 
     +   iadoy.eq.-32768 .or. 
     +   iahr .eq.-32768 .or. 
     +   iam  .eq.-32768 .or. 
     +   ias  .eq.-32768 .or. 
     +   iats .eq.-32768) .and.iferr.ge.0) iferr=-ifield
C 
C  ANTENNA'S CALCULATED LONGITUDE LIKE COORDINATE 
C 
      anlon=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C                       LATITUDE LIKE COORDINATEU 
C 
      anlat=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  TRACKING ERROR FOR LONGITUDE LIKE COORDIANTER
C 
      erlon=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C                     LATITUDE LIKE COORDINATE
C 
      erlat=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
      return
      end 
