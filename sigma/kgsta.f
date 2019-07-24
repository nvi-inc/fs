      logical function kgsta(lu,idcb,ferrln,ferrlt,iibuf,jbuf,il)
C
      dimension idcb(1)
      integer*2 jbuf(1)
      integer ichcm_ch
      character*(*) iibuf
C
      logical kfmp,kglin
C
      integer*2 lmerr(15)
      integer*2 lpeof(19)
      integer*2 lderr(37)
C
      data lmerr  /  27,2h$f,2hit,2h_s,2hta,2hts,2h s,2hec,2hti,2hon,
     /             2h m,2his,2hsi,2hng,2h_ /
C          $fit_stats section missing
      data lpeof  /  36,2hpr,2hem,2hat,2hur,2he ,2hen,2hd ,2hof,2h $,
     /             2hfi,2ht_,2hst,2hat,2hs ,2hse,2hct,2hio,2hn_/
C          premature end of $fit_stats section
      data lderr  /  72,2hfi,2hel,2hd ,2h  ,2h i,2hn ,2hre,2hco,2hrd,
     /             2h  ,2h  ,2h i,2hn ,2h$f,2hit,2h_s,2hta,2hts,2h s,
     /             2hec,2hti,2hon,2h c,2hou,2hld,2h n,2hot,2h b,2he ,
     /             2hde,2hco,2hde,2hd_,2h  ,2h  ,2h  /
C        field    in record     in $fit_stats section could not be decoded
50    continue
      kgsta=kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
      if (kgsta) return
      if (len.lt.0) goto  8015
      if (ichcm_ch(jbuf,1,'$fit_stats').ne.0) goto 50
C
      irec=0
90    continue
      kgsta=kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
      if(kgsta) return
      if(len.lt.0) goto 8010
      if (ichcm_ch(jbuf,1,'$').ne.0) goto 95
      call unget(jbuf,ierr,len)
      goto 8010
C
95    continue
C
      irec=irec+1
      iferr=0
      ifc=1
      ilc=len*2
      goto (100,200),  irec
C
100   continue
      dum=gtrel(jbuf,ifc,ilc,ifield,iferr)
      dum=gtrel(jbuf,ifc,ilc,ifield,iferr)
      dum=gtrel(jbuf,ifc,ilc,ifield,iferr)
      dum=gtrel(jbuf,ifc,ilc,ifield,iferr)
      dum=gtrel(jbuf,ifc,ilc,ifield,iferr)
      ferrln=gtrel(jbuf,ifc,ilc,ifield,iferr)
      ferrlt=gtrel(jbuf,ifc,ilc,ifield,iferr)
      if (iferr.ne.0) goto 8020
      goto 90
C
200   continue
      goto 9000
C
C CHECK FOR PREMATURE END OF SECTION
C
8010  continue
      if (irec.eq.1) return
      inc=ib2as(irec+1,lpeof(2),45,2)
      kgsta=kfmp(lu,0,lpeof(2),lpeof(1),iibuf,0,1)
      goto 9000
C
C section missing
C
8015  continue
      kgsta=kfmp(lu,0,lmerr(2),lmerr(1),iibuf,0,1)
      goto 9000
C
C DECODE ERROR
C
8020  continue
      inc=ib2as(-iferr,lderr(2),7,2)
      inc=ib2as(irec,lderr(2),20,3)
      kgsta=kfmp(lu,0,lderr(2),lderr(1),iibuf,0,1)
      goto 9000
C
9000  continue
C
      return
      end
