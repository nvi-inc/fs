      logical function kgant(lu,idcb,lant,laxis,iibuf,jbuf,il)

      integer*2 idcb(1)
      integer*2 jbuf(1),laxis(2),lant(5)
      character*(*) iibuf
C
      logical kfmp,kglin
C
      integer*2 lmerr(14),lpeof(18),leerr(21),lferr(24),lderr(33)
      integer ichcm_ch
C
      data lmerr  /  25,2H$a,2Hnt,2Hen,2Hna,2H s,2Hec,2Hti,2Hon,2H m,
     /             2His,2Hsi,2Hng,2H_ /
C          $antenna section missing_
      data lpeof  /  34,2Hpr,2Hem,2Hat,2Hur,2He ,2Hen,2Hd ,2Hof,2H $,
     /             2Han,2Hte,2Hnn,2Ha ,2Hse,2Hct,2Hio,2Hn_/
C          premature end of $antenna section_
      data leerr  /  39,2Hex,2Htr,2Ha ,2Hre,2Hco,2Hrd,2H f,2Hou,2Hnd,
     /             2H i,2Hn ,2H$a,2Hnt,2Hen,2Hna,2H s,2Hec,2Hti,2Hon,
     /             2H_ /
C          extra record found in $antenna section_
      data lferr  /  46,2Hex,2Htr,2Ha ,2Hfi,2Hel,2Hd ,2Hin,2H r,2Hec,
     /             2Hor,2Hd ,2H  ,2H  ,2Hin,2H $,2Han,2Hte,2Hnn,2Ha ,
     /             2Hse,2Hct,2Hio,2Hn_/
C          extra field in record     in $antenna section_
      data lderr  /  64,2Hfi,2Hel,2Hd ,2H  ,2H i,2Hn ,2Hre,2Hco,2Hrd,
     /             2H  ,2H  ,2H i,2Hn ,2H$a,2Hnt,2Hen,2Hna,2H s,2Hec,
     /             2Hti,2Hon,2H c,2Hou,2Hld,2H n,2Hot,2H b,2He ,2Hde,
     /             2Hco,2Hde,2Hd_/
C          field  in record  in $antenna section could not be decoded_

50    continue
      kgant=kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
      if (kgant) return
      if (len.lt.0) goto  8015
      if (ichcm_ch(jbuf,1,'$antenna').ne.0) goto 50
C
      irec=0
90    continue
      kgant=kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
      if (kgant) return
      if (len.lt.0) goto 8010
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
      call gtchr(lant,1,8,jbuf,ifc,ilc,ifield,iferr)
      call gtchr(laxis,1,4,jbuf,ifc,ilc,ifield,iferr) 
      if (iferr.ne.0) goto 8020 
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ic1.gt.0) goto 8005 
      goto 90
C 
200   continue
      kgant=kfmp(lu,0,leerr(2),leerr(1),iibuf,0,1)
      goto 9000
C 
C EXTRA FIELD ERROR 
C 
8005  continue
      inc=ib2as(irec,lferr(2),23,3) 
      kgant=kfmp(lu,0,lferr(2),lferr(1),iibuf,0,1)
      goto 9000
C 
C CHECK FOR PREMATURE END OF SECTION
C 
8010  continue
      if (irec.eq.1) return
      inc=ib2as(irec+1,lpeof(2),45,2) 
      kgant=kfmp(lu,0,lpeof(2),lpeof(1),iibuf,0,1)
      goto 9000
C 
C section missing 
C 
8015  continue
      kgant=kfmp(lu,0,lmerr(2),lmerr(1),iibuf,0,1)
      goto 9000
C 
C DECODE ERROR
C
8020  continue
      inc=ib2as(-iferr,lderr(2),7,2)
      inc=ib2as(irec,lderr(2),20,3)
      kgant=kfmp(lu,0,lderr(2),lderr(1),iibuf,0,1)
      goto 9000
C
9000  continue

      return
      end
