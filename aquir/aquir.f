      program aquir
C
      logical kinit,kgetc,knup
C
      real cra(200),cdec(200),cepoch(200),azar(37),elar(36)
      integer*2 jbuf(120),lname(5,200),lcpre(6,200),lcpos(6,200)
      character*63 icbuf
      integer iwpre(200),iwfiv(200),iwonof(200),iwpeak(200),iwpos(200)
      integer*2 lset(6),lter(6),lwho
      logical kbreak
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
      data il/120/,msorc/200/,mprc/6/,ierr/0/,mc/5/,lwho/2Haq/
      data imsmax/36/
c
      call setup_fscom
 1    continue
      call wait_prog('aquir',ip)
      call read_fscom
C
C  GET RID OF ANY BREAKS THAT WERE HANGING AROUND
C
2     continue
      if (kbreak('aquir')) goto 2
C
      if (kinit(icbuf)) goto 10020
C
      if (kgetc(icbuf,jbuf,il,lset,iwset,lter,iwter,azar,
     +  elar,imask,imsmax,elmax,lname,cra,cdec,cepoch,lcpre,iwpre,iwfiv,
     +  iwonof,iwpeak,lcpos,iwpos,nsorc,mc,msorc,mprc,isrcwt,isrcld))
     +  goto 10020
C
      call scmd(lset,iwset,mprc,ierr)
      if (ierr.ne.0) goto 10010
C
10    continue
      do 100 i=1,nsorc
C
      if(knup(lname(1,i),cra(i),cdec(i),cepoch(i),az,el,azar,elar,imask,
     +   elmax,mc,isrcld)) goto 100
C
      call ssrc(lname(1,i),cra(i),cdec(i),cepoch(i),jbuf,il,ierr)
      if (ierr.ne.0) goto 10010
C
      call onsor(isrcwt,ierr)
      if (ierr.eq.-20) goto 100
      if (ierr.ne.0) goto 10010
C
      call scmd(lcpre(1,i),iwpre(i),mprc,ierr)
      if (ierr.ne.0) goto 10010
C
      call sctl('fivept','fivpt',iwfiv(i),ierr)
      if (ierr.ne.0) goto 10010
C
      call sctl('onoff','onoff',iwonof(i),ierr)
      if (ierr.ne.0) goto 10010
C
      call sctl('peakf','peakf',iwpeak(i),ierr)
      if (ierr.ne.0) goto 10010
C
      call scmd(lcpos(1,i),iwpos(i),mprc,ierr)
      if (ierr.ne.0) goto 10010
C
100   continue
      call susp(2,2)
      if (kbreak('aquir')) goto 200
      goto 10
C
200   continue
      ierr=-1
      goto 10010
C
10010 continue
      if(ierr.eq.-2) goto 11000     !fs is gone
      if (ierr.gt.-2) goto 10015
      call logit7ic(idum,idum,idum,-1,ierr,lwho,'er')
      goto 11000
C
10015 continue
      call scmd(lter,iwter,mprc,jerr)
      call logit7ic(idum,idum,idum,-1,ierr,lwho,'br')
      goto 11000
C
10020 continue
      goto 11000
C
11000 continue
      goto 1
      end
