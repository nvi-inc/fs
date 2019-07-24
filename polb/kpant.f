      logical function kpant(lut,idcb,lant,laxis,ibuf,il,lst,iobuf)

      dimension idcb(1)
      integer*2 ibuf(1),lant(1),laxis(1)
      character*(*) iobuf
      logical kpout
C
      call ifill_ch(ibuf,1,il,' ')
      inext=1
      inext=ichmv(ibuf,inext,2H  ,1,2)
      inext=ichmv(ibuf,inext,lant,1,8)
      inext=ichmv(ibuf,inext,2H  ,1,2)
C
      inext=ichmv(ibuf,inext,laxis,1,4)
      inext=ichmv(ibuf,inext,2H  ,1,2)
C
      if(0.eq.mod(inext,2)) inext=ichmv(ibuf,inext,2H  ,1,1)
      kpant=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      return
      end
