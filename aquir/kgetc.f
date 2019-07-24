      logical function kgetc(icbuf,jbuf,il,lset,iwset,
     +         lter,iwter,azar,elar,imask,imsmax,elmax,
     +         lname,cra,cdec,cepoch,lcpre,iwpre,
     +         iwfiv,iwonof,iwpeak,lcpos,iwpos,
     +         nsorc,mc,msorc,mprc,isrcwt,isrcld)
C
      double precision das2b
      character*(*) icbuf
      integer*2 lset(mprc),lter(mprc),lname(mc,msorc),lcpre(mprc,msorc)
      integer*2 lcpos(mprc,msorc),jbuf(1),idum(4)
      real cra(msorc),cdec(msorc),cepoch(msorc),azar(1),elar(1)
      integer iwpre(msorc),iwfiv(msorc),iwonof(msorc),iwpeak(msorc)
      integer iwpos(msorc)
C
      logical kfmp,kfild,kreof,kopn,kread,kif
      integer idcb(1)
C
      integer fmpread, ichcm_ch, trimlen
      integer*2 lnosr( 9),l2mny(18)
      character*18 lnosrc
      character*36 l2mnyc
      data lnosrc /  'no source records '/
      data l2mnyc /  'too many source records, maximum is '/
      data mrec/2/
C
      luz=1
      call char2hol(lnosrc,lnosr,1,18)
      lnosrs=trimlen(lnosrc)
      call char2hol(l2mnyc,l2mny,1,36)
      l2mnys=trimlen(l2mnyc)
      kgetc=.true.
      ic=ib2as(msorc,idum,1,o'100000'+8)
C
C   OPEN THE DATA FILE
C
      call fmpopen(idcb,icbuf,ierr,'r+',id)
      if (kopn(luz,ierr,icbuf,0)) goto 9100
C
      ierr=0
      irec=0
      iferr=0
      imask=0
C
50    continue
      if (kfild(luz,iferr,-iferr,irec,icbuf)) goto 8050
      if (irec.ge.mrec) goto 200
      len = fmpread(idcb,ierr,jbuf,il*2)
      if (kreof(luz,ierr,len,irec+1,icbuf)) goto 8060
C
      ilc=len
      ifc=1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ic1.le.0) goto 50
      if (ichcm_ch(jbuf,1,'*').eq.0) goto 50
      irec=irec+1
      ifc=1
      ifield=0
C
C GET DATA
C
      if (irec.eq.1) then
        call depar(jbuf,ifc,ilc,lset,iwset,lter,iwter,elmax,mprc,
     +                 iferr,isrcwt,isrcld)
      else
        call demas(jbuf,ifc,ilc,azar,elar,imask,imsmax,iferr)
        if (imask.le.0) irec=irec-1
      endif
      goto 50
C
C  SOURCE AND PROCEDURE DATA
C
200   continue
      ierr=0
      iferr=0
      i=0
C
250   continue
      if (kfild(luz,iferr,-iferr,irec,icbuf)) goto 8050
      len = fmpread(idcb,ierr,jbuf,il*2)
      if (kif(lnosr,lnosrs,ib,ic1,ic2,len.eq.-1.and.i.eq.0,luz))
     +  goto 9000
      if (len.eq.-1) goto 8900
C
      if (kread(luz,ierr,irec+1,icbuf)) goto 8060
C
      ilc=len
      ifc=1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ic1.le.0) goto 250
      if (ichcm_ch(jbuf,1,'*').eq.0) goto 250 
      irec=irec+1 
      ifield=0
      ifc=1 
C 
C GET DATA
C
      i=i+1
      if (kif(l2mny,l2mnys,idum,1,ic,i.gt.msorc,luz))
     +  goto 9000
      call delne(jbuf,ifc,ilc,lname(1,i),cra(i),cdec(i),cepoch(i),
     +     lcpre(1,i),iwpre(i),iwfiv(i),iwonof(i),iwpeak(i),
     +     lcpos(1,i),iwpos(i),mc,mprc,iferr)
      goto 250
C
C FIELD ERROR
C
8050  continue
      ierr=-998
      goto 9000
C
C READ OR EOF ERROR
C
8060  continue
      if(ierr.eq.0) ierr=-999
      goto 9000
C
C DONE
C 
8900  continue
      nsorc=i 
      kgetc=.false.
      goto 9000
C
C
C CLOSE DCB
C
9000  continue
      call fmpclose(idcb,ierr)
C
C JUST EXIT
C
9100  continue
C
      return
      end
