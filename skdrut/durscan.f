      integer function durscan(ibuf,nch,idur)

C DURSCAN add the duration to the scan line
C NOTE: ibuf and nch are modified on return.
C History
C 970722 nrv New. Removed from addscan and newscan

C Input AND Output
      integer*2 ibuf(*)
      integer nch ! character to start with in ibuf
      integer idur ! duration in seconds

C Local
      integer*2 ibufx(4)
      integer i
      integer ib2as ! function

C  Convert the integer into a temporary buffer because
C  ib2as can't handle array indices greater than 256.
      i = ib2as(idur,ibufx,1,5) ! put into temporary buffer
C  Now move the converted value into the buffer
      nch = ichmv(ibuf,nch,ibufx,1,5)
      durscan=nch

      return
      end
