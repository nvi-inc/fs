      logical function kpst(lut,idcb,d1,d2,d3,d4,d6,igp,inp,
     +                      iobuf,lst,ibuf,il)
C
      double precision d1,d2,d3,d4,d6
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
C
      inext=1
      inext=ichmv(ibuf,inext,4H    ,1,4)
      inext=inext+jr2as(s1,ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(s2,ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(s3,ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(s4,ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,1)
      inext=inext+jr2as(s6,ibuf,inext,-10,5,il)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(igp,ibuf,inext,5)
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=inext+ib2as(inp,ibuf,inext,5)
C
      if (0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
      kpst=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
