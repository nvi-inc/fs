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
      if (.not.kuse) inext=ichmv_ch(ibuf,inext,' 0  ')
      if (kuse) inext=ichmv_ch(ibuf,inext,' 1  ')
      inext=inext+jd2as(ar1*rad2deg,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jd2as(ar2*rad2deg,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(sngl(ar3*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(sngl(ar4*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(sngl(ar5*rad2deg),ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
C
      if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
      kpdat=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
