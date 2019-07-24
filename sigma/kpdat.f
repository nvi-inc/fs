      logical function kpdat(lu,idcbo,lst,kuse,ich,ic,jbuf,il,iobuf)
C
      integer*2 jbuf(1)
      logical kuse,kpout
      character*(*) iobuf
C
      iuse=0
      if (kuse) iuse=1
      idum=ib2as(iuse,jbuf,ich,1)
      kpdat=kpout(lu,idcbo,jbuf,ic,iobuf,lst)
C
      return
      end
