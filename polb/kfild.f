      logical function kfild(lut,iferr,ifield,irec,ipbuf)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 lfel(11),lrec(9),lin(3)
C
      data lfel   /  20,2Her,2Hro,2Hr ,2Hin,2H f,2Hie,2Hld,2H x,2Hxx,
     /             2Hx_/
C          error in field xxxx_
      data lrec   /  16,2H i,2Hn ,2Hre,2Hco,2Hrd,2H x,2Hxx,2Hx_/
C           in record xxxx_
      data lin    /   4,2H i,2Hn_/
C           in_
      kfild=.false.
      if (iferr.ge.0) return
C
      ifc=16
      ifc=ifc+ib2as(ifield,lfel(2),ifc,o'100000'+4)
      ifc=ichmv(lfel(2),ifc,2H_  ,1,1)
      call po_put_i(lfel(2),ifc)
C
      ifc=12
      ifc=ifc+ib2as(irec,lrec(2),ifc,o'100000'+4)
      ifc=ichmv(lrec(2),ifc,2H_  ,1,1)
      call po_put_i(lrec(2),ifc)
      kfild=kfmp(lut,0,lin(2),lin(1),ipbuf,0,1)

      return
      end
