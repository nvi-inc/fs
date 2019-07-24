      logical function kpout(lut,idcb,ibuf,nchars,iobuf,lst)
C
      integer*2 ibuf(1)
      integer idcb(2)
      integer lut,lst
      logical kwrit
      integer fmpwrite2
      character*(*) iobuf

C
      if (lst.gt.0) call po_put_i(ibuf,nchars)
C
      id = fmpwrite2(idcb,ierr,ibuf,nchars)
      kpout=kwrit(lut,ierr,iobuf)
C
      return
      end
