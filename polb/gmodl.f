      subroutine gmodl(lut,idcb,imbuf,pcof,mpar,ipar,phi,
     +                 imdl,it,jbuf,il,ierr,idcbs)
      double precision das2b,gtdbl
      dimension idcb(1),ipar(mpar),it(6)
      integer*2 jbuf(1)
      double precision pcof(mpar),phi
      character*(*) imbuf
C
      include '../include/dpi.i'
      logical kopn,kfmp,kdum
C
      integer*2   lrerr(10)
      integer*2   lpeof(25)
      integer*2   leerr(11)
      integer*2   lderr(23)
      integer fmpread,ichcm_ch
C
C   OPEN THE DATA FILE
C
      data lrerr  /  18,2Hre,2Had,2Hin,2Hg ,2Hre,2Hco,2Hrd,2H  ,2H _/
C          reading record
      data lpeof  /  47,2Hpr,2Hem,2Hat,2Hur,2He ,2Hen,2Hd-,2Hof,2H-f,
     /             2Hil,2He ,2Hbe,2Hfo,2Hre,2H r,2Hea,2Hdi,2Hng,2H r,
     /             2Hec,2Hor,2Hd ,2H  ,2H_ /
C          premature end-of-file before reading record
      data leerr  /  19,2Hex,2Htr,2Ha ,2Hre,2Hco,2Hrd,2H f,2Hou,2Hnd,
     /             2H_ /
C          extra record found
      data lderr  /  44,2Hfi,2Hel,2Hd ,2H  ,2H i,2Hn ,2Hre,2Hco,2Hrd,
     /             2H  ,2H  ,2H c,2Hou,2Hld,2H n,2Hot,2H b,2He ,2Hde,
     /             2Hco,2Hde,2Hd_/
C          field    in record     could not be decoded

      call fmpopen(idcb,imbuf,ierr,'r',idum)
      if (kopn(lut,ierr,imbuf,4)) goto 9000
C
      irec=0
      iline=0
50    continue
      len = fmpread(idcb,ierr,jbuf,il*2)
      if (ierr.ne.0) goto 8005
      if (len.eq.-1) goto 8010
C
      if (ichcm_ch(jbuf,1,'*').eq.0) goto 50
      irec=irec+1
      ilc=len
      ifc=1
      ifield=0
      iferr=0
      goto (100,200,300,300,300,300),  irec
C
C  MODEL # AND DATE
C
100   continue
      imdl=igtbn(jbuf,ifc,ilc,ifield,iferr)
      it(6)=igtbn(jbuf,ifc,ilc,ifield,iferr)
      it(5)=igtbn(jbuf,ifc,ilc,ifield,iferr)
      it(4)=igtbn(jbuf,ifc,ilc,ifield,iferr)
      it(3)=igtbn(jbuf,ifc,ilc,ifield,iferr)
      it(2)=igtbn(jbuf,ifc,ilc,ifield,iferr)
      it(1)=0
      if (iferr.ne.0) goto 8020
      goto 50
C
C  Parameter Control Record
C
200   continue
      phi=gtdbl(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      do i=1,mpar
        ipar(i)=igtbn(jbuf,ifc,ilc,ifield,iferr)
      enddo
      if (iferr.ne.0) goto 8020
      goto 50
C
300   continue
      iline=iline+1
      do i=(iline-1)*5+1,iline*5
        pcof(i) = gtdbl(jbuf,ifc,ilc,ifield,iferr)*deg2rad
        if (iferr.ne.0) goto 8020
      enddo
      if (iline.eq.4) goto 9000
      goto 50
C
400   continue
      kdum=kfmp(lut,0,leerr(2),leerr(1),imbuf,0,1)
      ierr=-12
      goto 9000
C
C  READ ERROR
C
8005  continue
      inc=ib2as(irec+1,lrerr(2),16,2)
      kdum=kfmp(lut,ierr,lrerr(2),lrerr(1),imbuf,0,0)
      goto 9000
C
C PREMATURE END OF FILE
C
8010  continue
      inc=ib2as(irec+1,lpeof(2),45,2)
      kdum=kfmp(lut,0,lpeof(2),lpeof(1),imbuf,0,1)
      ierr=-12
      goto 9000
C
C DECODE ERROR
C
8020  continue
      inc=ib2as(-iferr,lderr(2),7,2)
      inc=ib2as(irec,lderr(2),20,3)
      kdum=kfmp(lut,0,lderr(2),lderr(1),imbuf,0,1)
      ierr=iferr
      goto 9000
C
9000  continue
      call fmpclose(idcb,ierr)

      return
      end
