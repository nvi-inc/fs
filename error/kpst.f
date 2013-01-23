      logical function kpst(lut,idcb,d1,d2,d3,d4,d6,d7,d8,igp,inp,
     +                      iobuf,lst,ibuf,il)
C
      double precision d1,d2,d3,d4,d6,d7,d8
      integer*2 ibuf(1)
      character*(*) iobuf
      logical kpout
      include '../include/dpi.i'
C
      s1=d1*rad2deg
      s2=d2*rad2deg
      s3=d3*rad2deg
      s4=d4*rad2deg
      s6=d6*rad2deg
      s7=d7*rad2deg
      s8=d8*rad2deg
C
      inext=1
      inext=ichmv_ch(ibuf,inext,'    ')
      inext=inext+jr2as(s1,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s2,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s3,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s4,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s6,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(igp,ibuf,inext,5)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(inp,ibuf,inext,5)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s7,ibuf,inext,-10,5,il)
      inext=ichmv_ch(ibuf,inext,' ')
      inext=inext+jr2as(s8,ibuf,inext,-10,5,il)
C
      if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
      kpst=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
