      subroutine jmvbits(ifrom,ist,ilen,ito,itost)
      implicit none
      integer*4 ifrom,ist,ilen,ito,itost
c
      integer*4 ibits,imask
c
      imask=not(lshift(not(0),ilen))
      ibits=lshift(and(rshift(ifrom,ist),imask),itost)
      imask=not(lshift(imask,itost))
      ito=or(and(ito,imask),ibits)
c
      return
      end
