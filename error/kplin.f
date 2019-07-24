      logical function kplin(lut,idcb,parr,np,qarr,nq,imdl,it,ipar,
     + phi,iobuf,lst,ibuf,il)
C
      dimension parr(np),qarr(nq),it(6),ipar(np)
      integer*2 ibuf(1)
      character*(*) iobuf
      double precision parr,qarr,phi
      include '../include/dpi.i'
C
      logical kpout
C
      data nline/5/
C
      kplin=.false.
C
      if (np.le.0) return
C
      kplin=kpout(lut,idcb,2H* ,2,iobuf,lst)
      if (kplin) return
C
      inext=1
      inext=ichmv(ibuf,1,2H  ,1,2)
      inext=inext+ib2as(imdl,ibuf,inext,o'40000'+o'400'*5+5)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(it(6),ibuf,inext,o'40000'+o'400'*4+4)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(it(5),ibuf,inext,o'40000'+o'400'*3+3)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(it(4),ibuf,inext,o'40000'+o'400'*2+2)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(it(3),ibuf,inext,o'40000'+o'400'*2+2)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(it(2),ibuf,inext,o'40000'+o'400'*2+2)
      inext=ichmv(ibuf,inext,2H  ,1,1)
C
      kplin=kpout(lut,idcb,ibuf,inext,iobuf,lst)
      if (kplin) return
C
      kplin=kpout(lut,idcb,2H* ,2,iobuf,lst)
      if (kplin) return
C
      inext=1
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+jr2as(sngl(phi*rad2deg),ibuf,inext,-8,4,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      do i=1,np
        inext=ichmv(ibuf,inext,2H  ,1,1)
        inext=inext+ib2as(abs(ipar(i)),ibuf,inext,1)
        if (mod(i,5).eq.0.and.i.ne.np) inext=ichmv(ibuf,inext,2H  ,1,1)
      enddo
C
      if (0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
  
      kplin=kpout(lut,idcb,ibuf,inext-1,iobuf,lst)
      if (kplin) return
C
      kplin=kpout(lut,idcb,2H* ,2,iobuf,lst)
      if (kplin) return
C
      do j=1,np,nline
        inext=1
        do i=j,min0(j+nline-1,np)
          inext=ichmv(ibuf,inext,2H  ,1,2)
          inext=inext+jr2as(sngl(parr(i)*rad2deg),ibuf,inext,-13,10,il)
        enddo
C
        if (0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
        kplin=kpout(lut,idcb,ibuf,inext-1,iobuf,lst)
        if (kplin) return
        if (nq.le.0) goto 25
C
        inext=1
        do i=j,min0(j+nline-1,nq)
          inext=ichmv(ibuf,inext,2H  ,1,2)
          inext=inext+jr2as(sngl(qarr(i)*rad2deg),ibuf,inext,-13,10,il)
        enddo
C
        if (0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
        kplin=kpout(lut,idcb,ibuf,inext-1,iobuf,lst)
        if (kplin) return
C
25      continue
        kplin=kpout(lut,idcb,2H* ,2,iobuf,lst)
        if (kplin) return
      enddo
C
      return
      end
