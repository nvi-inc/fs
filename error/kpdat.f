      logical function kpdat(lut,idcb,kuse,ar1,ar2,ar3,ar4,ar5,
     +                       mc,iobuf,lst,ibuf,il)
C
      dimension idcb(1)
      integer*2 ibuf(1)
      character*(*) iobuf
C
      double precision ar1,ar2
      logical kpout,kuse
      include '../include/dpi.i'
C
      inext=1
      if (.not.kuse) inext=ichmv(ibuf,inext,4H 0  ,1,4)
      if (kuse) inext=ichmv(ibuf,inext,4h 1  ,1,4)
      inext=inext+jr2as(sngl(ar1*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(sngl(ar2*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(sngl(ar3*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(sngl(ar4*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(sngl(ar5*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
C
      if (0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
      kpdat=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
