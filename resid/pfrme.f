      subroutine pfrme(ibuf,lut,idcb,iobuf,lst)
C
      character*(*) iobuf
      integer*2 ibuf(1), idcb(1)
C
C  FRaMe ahead, i.e dump the picture
C
      common/pplot/ichars,iwidx,iwidy,
     +             ixmin,ixmax,iymin,iymax,
     +             xmin,xmax,ymin,ymax,
     +             rotat(2,2)
C
      iwds=iwidx/2
C
      do i=1,iwidy 
        ist=(i-1)*iwds+1
        if (kpout(lut,idcb,ibuf(ist),iwds,iobuf,lst).ne.0) stop
      enddo
C 
      return
      end 
