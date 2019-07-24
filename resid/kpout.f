      logical function kpout(lut,idcb,ibuf,nchars,iobuf,lst)
C
      logical kwrit
      integer*2 ibuf(1), idcb(1)
      character*(*) iobuf
      integer lut,ierr,nchars
C
      integer id, fmpwrite2
C
      id = 0
      ierr = 0

      if(lst.gt.0) call po_put_i(ibuf,nchars*2)
C
      id = fmpwrite2(idcb,ierr,ibuf,nchars*2)
      kpout=kwrit(lut,ierr,iobuf)
C
      return
      end
