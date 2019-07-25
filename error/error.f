      program error
C
      include '../include/dpi.i'
C
      logical kinit,kgpnt,kopn,koutp,kpst,kplin,kpdat,kpout_ch,kpfit
      logical kif,kgetm,kptri,kpant,kgant,kbit,kpcon,kfixed
C
      double precision lonsum,lonrms,latsum,latrms,dirms
      double precision wlnsum,wltsum,wdisum
C
      logical kuse
C
      double precision lat,lon
      real latoff,lonoff,latres,lonres
      real latr,ltofr,lonr,lnofr
C
      external fln,flt0
      double precision fln,flt0
C
      character*64 iibuf,iobuf,imbuf
      dimension ireg(2),ldum(3)
      integer*2 jbuf(50),lant(4),laxis(2)
      dimension lon(600),lat(600),wln(600),wlt(600)
      dimension lonoff(600),latoff(600),luse(32)
      dimension latres(600),lonres(600)
      dimension idcbo(2),it(6),ipar(20),ito(6),ispar(20)
      double precision pcof(20),pcofer(20),phi,spcof(20)
      double precision a(210),b(20),aux(20),scale(20),ddum
C
      equivalence (ireg,reg)
C
      integer ichcm_ch
      integer*2 l2mny(17)
      integer*2 lnopt(9)
C
      data l2mny  /  32,2hto,2ho ,2hma,2hn ,2hin,2hpu,2ht ,2hpo,2hin,
     /             2hts,2h, ,2hli,2hmi,2ht ,2his,2h _/
C          too man input points, limit is
      data lnopt  /  15,2hno,2h i,2hnp,2hut,2h p,2hoi,2hnt,2hs /
C          no input points
      data il/50/,mpts/600/,mpar/20/,itry/-1/,tol/1e-3/
      data mc/5/,npar/20/
      data feclon/0.0/,feclat/0.0/
C
      call fc_setup_ids
c
      ic=ib2as(mpts,ldum,1,o'100000'+6)
      call fc_rte_time(it,it(6))
C
      if (kinit(lu,iibuf,iobuf,iapp,imbuf,lst)) goto 10010
C
      if (kgetm(lu,imbuf,jbuf,il,idcbo,idcbos,pcof,mpar,ipar,phi,
     +         imdl,ito)) goto 10010
C
      call fmpopen(idcbo,iibuf,ierr,'r+',idcbos)
      if (kopn(lu,ierr,iibuf,0)) goto 10010
C
      if (kgant(lu,idcbo,lant,laxis,iibuf,jbuf,il)) goto 10000
C
      inp=0
C
10    continue
      if (kgpnt(lu,idcbo,kuse,lonr,latr,lnofr,ltofr,wlnr,wltr,
     +   mc,ilen,inp,iibuf,jbuf,il)) goto 10000
      if (ilen.lt.0.or.(ichcm_ch(jbuf,1,'$').eq.0)) goto 20
      if (kif(l2mny(2),l2mny(1),ldum,1,ic,inp.ge.mpts,lu)) goto 10000
      inp=inp+1
C
      if (inp.eq.1) then
        emnln=wlnr
        emnlt=wltr
      endif
C
      call sbit(luse,inp,0)
      if (kuse) then
        call sbit(luse,inp,1)
        emnln=min(emnln,wlnr)
        emnlt=min(emnlt,wltr)
      endif
      lon(inp)=lonr
      lat(inp)=latr
      lonoff(inp)=lnofr
      latoff(inp)=ltofr
      wln(inp)=wlnr
      wlt(inp)=wltr
      goto 10
C
20    continue
      if (kif(lnopt(2),lnopt(1),idum,0,0,inp.eq.0,lu)) goto 10000
      call fmpclose(idcbo,ierr)
      if (koutp(lu,idcbo,idcbos,iapp,iobuf)) goto 10000
C
      if (kpout_ch(lu,idcbo,'$antenna',iobuf,lst)) goto 10000
      if (kpant(lu,idcbo,lant,laxis,jbuf,il,lst,iobuf)) goto 10000
C
      if (kpout_ch(lu,idcbo,'$observed ',iobuf,lst)) goto 10000
      call inism(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms,
     &           wdisum,igp)
      do i=1,inp
        coslt=cos(lat(i))
        distr=sqrt(lonoff(i)*lonoff(i)*coslt*coslt+latoff(i)*latoff(i))
        call incsm(luse,lonsum,lonrms,wlnsum,lonoff(i),wln(i),latsum,
     +             latrms,wltsum,latoff(i),wlt(i),dirms,wdisum,distr,
     +             i,igp,feclon,feclat,coslt)
        kuse=kbit(luse,i)
        if (kpdat(lu,idcbo,kuse,lon(i),lat(i),lonoff(i),latoff(i),distr,
     +           mc,iobuf,lst,jbuf,il)) goto 10000
      enddo
C
      if (kpout_ch(lu,idcbo,'$observed_stats ',iobuf,lst)) goto 10000
C
      call rstat(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms,wdisum,
     &           igp,lu)
C
      if (kpst(lu,idcbo,lonsum,lonrms,latsum,latrms,dirms,igp,inp,
     +        iobuf,lst,jbuf,il)) goto 10000
C
      call inism(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms,
     &           wdisum,igp)
C
      if (kpout_ch(lu,idcbo,'$old_model',iobuf,lst)) goto 10000
      if (kplin(lu,idcbo,pcof,mpar,ddum,0,imdl,ito,ipar,phi,iobuf,lst,
     +    jbuf,il)) goto 10000
      if (kpout_ch(lu,idcbo,'$uncorrected',iobuf,lst)) goto 10000
C
C PARAMETER FLAGS:
C
C    0 = DON'T USE
C    1 = USE
C    2 = HARDWIRED
C    3 = IF PRESENT, HARDWIRE OTHER PARMATERS WITH VALUES LESS THAN 3
C    4 = USE TO UNCORRECT DATA BUT DON'T RE-ESTIMATE
C
      kfixed=.false.
      do i=1,mpar
        kfixed=kfixed.or.ipar(i).eq.3
        if (ipar(i).lt.0.or.ipar(i).gt.4) then
       call po_put_c('parameter flag values must be 0 to 4 inclusive.')
          stop
        endif
      enddo
      do i=1,mpar
        ispar(i)=ipar(i)
        spcof(i)=pcof(i)
        if ((kfixed.and.ipar(i).lt.3).or.(ipar(i).eq.2)) then
          ipar(i)=0
          pcof(i)=0.0d0
        endif
      enddo
C
      do i=1,inp
        lonoff(i)=lonoff(i)+fln(0,lon(i),lat(i),pcof,ipar,phi)
        latoff(i)=latoff(i)+flt0(0,lon(i),lat(i),pcof,ipar,phi)
        coslt=cos(lat(i))
        distr=sqrt(lonoff(i)*lonoff(i)*coslt*coslt+latoff(i)*latoff(i))
C
        call incsm(luse,lonsum,lonrms,wlnsum,lonoff(i),wln(i),latsum,
     +             latrms,wltsum,latoff(i),wlt(i),dirms,wdisum,distr,
     +             i,igp,feclon,feclat,coslt)
        kuse=kbit(luse,i)
        if (kpdat(lu,idcbo,kuse,lon(i),lat(i),lonoff(i),latoff(i),distr,
     +     mc,iobuf,lst,jbuf,il)) goto 10000
C
      enddo
C
      call rstat(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms,wdisum,
     &           igp,lu)
C
      if (kpout_ch(lu,idcbo,'$uncorrected_stats',iobuf,lst))
     +  goto 10000
C
      if (kpst(lu,idcbo,lonsum,lonrms,latsum,latrms,dirms,igp,inp,
     +        iobuf,lst,jbuf,il)) goto 10000
C
C  FIX IPAR
C
      do i=1,mpar
        if(ipar(i).eq.4) then
          ipar(i)=0
          ispar(i)=0
          spcof(i)=0.0d0
          pcof(i)=0.0d0
        endif
        if(ipar(i).ne.0) npar=i
      enddo
C
C
      do itryfe=1,10
        if (itryfe.eq.1) goto 205
        if (nfree.le.0) goto 211
        iftry=itryfe
C
        call fecon(feclnn,fecltn,lonres,wln,latres,wlt,inp,luse,
     &           emnln,emnlt)
C
        if (abs(feclnn-feclon).le.0.01*feclnn.and.
     +     abs(fecltn-feclat).le.0.01*fecltn) goto 211
C
        feclon=feclnn
        feclat=fecltn
C
205     continue
        if (lst.ne.0)
     .    write(lst,9905) itryfe,feclon*rad2deg,feclat*rad2deg
9905    format(' iteration ',i3,'       fec:',2(1x,f10.5))
        call fit2(lon,lat,lonoff,latoff,wln,wlt,inp,pcof,pcofer,ipar,
     +   phi,aux,scale,a,b,npar,tol,itry,fln,flt0,rchi,rlnnr,rltnr,
     +   nfree,ierr,luse,igp,feclon,feclat,lonres,latres,rcond)
      enddo
      iftry=0
2105  continue
      feclon=0.0
      feclat=0.0
      call fit2(lon,lat,lonoff,latoff,wln,wlt,inp,pcof,pcofer,ipar,
     + phi,aux,scale,a,b,npar,tol,itry,fln,flt0,rchi,rlnnr,rltnr,
     + nfree,ierr,luse,igp,feclon,feclat,lonres,latres,rcond)
211   continue
C
      imdl=imdl+1
C
      if (kpout_ch(lu,idcbo,'$fit_data ',iobuf,lst)) goto 10000
C
      if (kplin(lu,idcbo,pcof,mpar,pcofer,mpar,imdl,it,ipar,phi,
     + iobuf,lst,jbuf,il))  goto 10000
C
      if (kpout_ch(lu,idcbo,'$fit_stats',iobuf,lst)) goto 10000
      if (kpfit(lu,idcbo,ierr,rchi,rlnnr,rltnr,nfree,feclon,feclat,
     +         iftry,iobuf,lst,jbuf,il)) goto 10000
C
      if (rcond.ne.0) then
        cond=1.0/rcond
      endif
      if (kpout_ch(lu,idcbo,'$conditions ',iobuf,lst)) goto 10000
      if (kpcon(lu,idcbo,cond,scale,npar,iobuf,lst,jbuf,il)) goto 10000
C
C     IF(KPOUT(LU,IDCBO,12H$COVARIANCE ,-12,IOBUF,LST)) GOTO 10000
C     IF(KPTRI(LU,IDCBO,A,NPAR,IOBUF,LST,JBUF,IL)) GOTO 10000
C
      nxpnt=0
      do i=1,npar
        nxpnt=nxpnt+i
        aux(i)=1.0d0
        div=dsqrt(a(nxpnt))
        if (div.gt.1e-10) aux(i)=1.0d0/div
      enddo
C
      nxpnt=0
      do i=1,npar
        do j=1,i
          a(nxpnt+j)=a(nxpnt+j)*aux(i)*aux(j)
        enddo
        nxpnt=nxpnt+i
      enddo
  
      if (kpout_ch(lu,idcbo,'$correlation',iobuf,lst)) goto 10000
      if (kptri(lu,idcbo,a,npar,iobuf,lst,jbuf,il)) goto 10000
C
      call inism(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms,
     &           wdisum,igp)
C
      if (kpout_ch(lu,idcbo,'$corrected',iobuf,lst)) goto 10000
C
      do i=1,inp
        coslt=cos(lat(i))
        distr=sqrt(lonres(i)*lonres(i)*coslt*coslt+latres(i)*latres(i))
C
        call incsm(luse,lonsum,lonrms,wlnsum,lonres(i),wln(i),latsum,
     +           latrms,wltsum,latres(i),wlt(i),dirms,wdisum,distr,
     +           i,igp,feclon,feclat,coslt)
C
        kuse=kbit(luse,i)
        if (kpdat(lu,idcbo,kuse,lon(i),lat(i),lonres(i),latres(i),
     +     distr,mc,iobuf,lst,jbuf,il)) goto 10000
      enddo
C
      call rstat(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms,wdisum,
     &           igp,lu)
C
      if (kpout_ch(lu,idcbo,'$corrected_stats',iobuf,lst)) goto 10000
C
      if (kpst(lu,idcbo,lonsum,lonrms,latsum,latrms,dirms,igp,inp,
     +        iobuf,lst,jbuf,il)) goto 10000
C
      do i=1,mpar
        if ((ispar(i).lt.3.and.kfixed).or.(ispar(i).eq.2)) then
          ipar(i)=ispar(i)
          pcof(i)=spcof(i)
        else if (ispar(i).eq.3) then
          ipar(i)=1
        endif
      enddo
C
      if (kpout_ch(lu,idcbo,'$new_model',iobuf,lst)) goto 10000
      if (kplin(lu,idcbo,pcof,mpar,ddum,0,imdl,it,ipar,phi,iobuf,lst,
     +    jbuf,il)) goto 10000
C
C
10000 continue
      call fmpclose(idcbo,ierr)
C
10010 continue
      end
