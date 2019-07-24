      logical function kpfit(lu,idcbo,ierr,rchi,rlnnr,rltnr,nfree,
     + feclon,feclat,iftry,iobuf,lst,ibuf,il)
C
      integer*2 ibuf(1)
      character*(*) iobuf
      logical kpout
      include '../include/dpi.i'
C
      inext=1
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(ierr,ibuf,inext,4)
      inext=ichmv(ibuf,inext,6H      ,1,5)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+jr2as(rchi,ibuf,inext,-6,3,il)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+jr2as(rlnnr,ibuf,inext,-6,3,il)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+jr2as(rltnr,ibuf,inext,-6,3,il)
      inext=ichmv(ibuf,inext,8H        ,1,7)
      inext=inext+ib2as(nfree,ibuf,inext,4)
      inext=ichmv(ibuf,inext,6H      ,1,4)
      inext=inext+jr2as(sngl(feclon*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(sngl(feclat*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(iftry,ibuf,inext,4)
      inext=ichmv(ibuf,inext,2H  ,1,2)
C
      if (0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
      kpfit=kpout(lu,idcbo,ibuf,inext,iobuf,lst)
C
      return
      end 
