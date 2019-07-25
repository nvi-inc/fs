      program sigma
C
      logical kinit,kgpnt,kopn,kif,koutp,kgsta,kuse
      logical kgdat,kpdat,kusen
C
      real latoff,lonoff
      real latr,lonr,ltofr,lnofr,lnofs,ltofs
C
      integer idcbi(2)
      character*63 iobuf,iibuf,imbuf
      dimension ireg(2),ldum(3),ip(5)
      integer*2 jbuf(50)
      dimension lonoff(500),latoff(500)
      integer idcbo(2),ichcm_ch
C
      equivalence (ireg,reg)
C
      integer*2 l2mny(23)
      integer*2 lnopt(15)
      integer*2 qtmnin(12)
      integer*2 qtfwin(11)
      integer*2 qedit(23)
      integer qnchar,qnc
C                  1234567890123456789012345678901
      data l2mny  /  43,2hto,2ho ,2hma,2hny,2h p,2hoi,2hnt,2hs ,2hin,
     /             2h e,2hrr,2hor,2h o,2hut,2hpu,2ht,,2h l,2him,2hit,
     /             2h i,2hs ,2h_ /
C          too many points in error output, limit is
      data lnopt  /  27,2hno,2h p,2hoi,2hnt,2hs ,2hfr,2hom,2h e,2hrr,
     /             2hor,2h o,2hut,2hpu,2ht /
C          no points from error output
      data qtmnin /  21,2hto,2ho ,2hma,2hny,2h i,2hnp,2hut,2h p,2hoi,
     /             2hnt,2hs /
C          too many input points
      data qtfwin /  20,2hto,2ho ,2hfe,2hw ,2hin,2hpu,2ht ,2hpo,2hin,
     /             2hts/
C          too few input points
      data qedit   /2Hed,2Hit,2H: ,2H  ,2H  ,2Hpo,2Hin,2Ht(,2Hs),
     /             2H r,2Hem,2Hov,2Hed,2H, ,2H  ,2H  ,2Hpo,2Hin,2Ht(,
     /             2Hs),2H a,2Hdd,2Hed/
      data qnchar /46/
C          edit:     point(s) removed,     point(s) added
      data il/50/,mpts/500/,idcbos/784/
      data ip/5*0/
C
      ic=ib2as(mpts,ldum,1,o'100000'+6)
C
      if (kinit(lu,iibuf,iobuf,iapp,imbuf,lst)) goto 10010
C
      call fmpopen(idcbo,imbuf,ierr,'r+',id)
      if (kopn(lu,ierr,imbuf,0)) goto 10010
C
      if (kgsta(lu,idcbo,ferrln,ferrlt,imbuf,jbuf,il)) goto 10005
C
      inp=0
10    continue
      if (kgpnt(lu,idcbo,kuse,lonr,latr,lnofr,ltofr,ilen,inp,imbuf,jbuf,
     +         il)) goto 10005
      if (ilen.lt.0.or.ichcm_ch(jbuf,1,'$').eq.0) goto 20
      if (kif(l2mny(2),l2mny(1),ldum,1,ic,inp.ge.mpts,lu)) goto 10005
      inp=inp+1
C
      lonoff(inp)=lnofr
      latoff(inp)=ltofr
      goto 10
C
20    continue
      if (kif(lnopt(2),lnopt(1),idum,0,0,inp.eq.0,lu)) goto 10005
C
      call fmpclose(idcbo,ierr)
C
      if (koutp(lu,idcbo,idcbos,iapp,iobuf)) goto 10010
C
      call fmpopen(idcbi,iibuf,ierr,'r+',id)
      if (kopn(lu,ierr,iibuf,0)) goto 10005
C
      iadd=0
      irem=0
      do i=1,inp
        if (kgdat(lu,idcbi,idcbo,lst,kuse,ich,ic,i-1,jbuf,il,iibuf,
     +     iobuf,lnofs,ltofs)) goto 10000
        if (ic.lt.0) goto 9990
        kusen=abs(lonoff(i)).le.3.0*sqrt(ferrln**2+lnofs**2).and.
     +        abs(latoff(i)).le.3.0*sqrt(ferrlt**2+ltofs**2)
        if (kpdat(lu,idcbo,lst,kusen,ich,ic,jbuf,il,iobuf)) goto 10000
        if (kusen.and..not.kuse ) iadd=iadd+1
        if(kuse .and..not.kusen) irem=irem+1
      enddo
C
      if (kgdat(lu,idcbi,idcbo,lst,kuse,ich,ic,inp,jbuf,il,iibuf,iobuf,
     +    lnofs,ltofs)) goto 10000
      if (ic.gt.0) goto 9980
      idum=ib2as(irem,qedit,7,3)
      idum=ib2as(iadd,qedit,29,3)
      call po_put_i(qedit,qnchar)
      ip(1)=irem
      ip(2)=iadd
      goto 10000
C
9980  continue
      qnc=qtmnin(1)
      call po_put_i(qtmnin(2),qnc)
      goto 10000
C
9990  continue
      qnc=qtfwin(1)
      call po_put_i(qtfwin(2),qnc)
      goto 10000
C
10000 continue
      call fmpclose(idcbi,ierr)
10005 continue
      call fmpclose(idcbo,ierr)
C
10010 continue
      write(6,'(1x)')
      call fc_exit(abs(irem)+abs(iadd))
C
      end
