      integer function gdscan(ibuf,nch,igdata)

C GDSCAN add the "good data offset" to the scan line
C NOTE: ibuf and nch are modified on return.
C History
C 970722 nrv New. Removed from addscan and newscan

C Called by: NEWSCAN

C Input AND Output
      integer*2 ibuf(*)
      integer nch ! character to start with in ibuf
      integer igdata ! good data offset in seconds

C Local
      integer*2 ibufx(4)
      integer i
      integer ib2as ! function

C  Convert the integer into a temporary buffer because
C  ib2as can't handle array indices greater than 256.
      i = ib2as(igdata,ibufx,1,5) ! put into temporary buffer
C  Now move the converted value into the buffer
      nch = ichmv(ibuf,nch,ibufx,1,5)
      gdscan=nch

      return
      end
