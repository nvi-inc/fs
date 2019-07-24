      logical function kpcon(lut,idcb,cond,scale,np,iobuf,lst,ibuf,il)
C
      integer*2 ibuf(1)
      double precision scale(1)
      character*(*) iobuf
C
      character*10 cbuf
      integer*2 ib(5)
      equivalence (cbuf,ib(1))
      logical kpout
C
      data nline/10/
C
      kpcon=.false.
C
      if(np.le.0) return
C
      kpcon=kpout(lut,idcb,2H* ,2,iobuf,lst)
      if(kpcon) return
C
      write(cbuf,'(2x,1pe8.2)') cond
      inext=1
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=ichmv(ibuf,inext,ib,1,10)
      if (0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
      kpcon=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      kpcon=kpout(lut,idcb,2h* ,2,iobuf,lst)
      if (kpcon) return
C
      do k=1,np,nline
        inext=1
        do i=k,min0(k+nline-1,np)
          inext=ichmv(ibuf,inext,2h  ,1,1)
          inext=inext+jr2as(sngl(scale(i)),ibuf,inext,-6,1,il)
        enddo
C
        if (0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
        kpcon=kpout(lut,idcb,ibuf,inext,iobuf,lst)
        if (kpcon) return
        kpcon=kpout(lut,idcb,2H* ,2,iobuf,lst)
        if (kpcon) return
      enddo
C
      return
      end
