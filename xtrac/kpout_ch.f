      logical function kpout_ch(lut,idcb,cbuf,iobuf,lst)
C
      integer idcb(1),lut,ierr
      character*(*) iobuf,cbuf
      integer*2 iarr(128)
      logical kpout
C
      if(len(cbuf).gt.256) stop 999
      call char2hol(cbuf,iarr,1,len(cbuf))
      kpout_ch=kpout(lut,idcb,iarr,len(cbuf),iobuf,lst)
      return
      end
