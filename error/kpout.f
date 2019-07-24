      logical function kpout(lut,idcb,ibuf,nchars,iobuf,lst)
C
      logical kwrit
      integer*2 idcb(1),ibuf(1)
      integer lut,ierr,nchars
      character*(*) iobuf
C
      integer id, fmpwrite2
C
      if(lst.gt.0) call po_put_i(ibuf,nchars)
C
      id = fmpwrite2(idcb,ierr,ibuf,nchars)
      kpout=kwrit(lut,ierr,iobuf)
C
      return
      end
