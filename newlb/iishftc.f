      integer*2 function iishftc(iar,inum,ifield)
      implicit none
      integer*2 iar
      integer inum,ifield
c
      integer*2 imask,ibits,imask2
c
      imask=not(lshift(not(0),ifield))
      ibits=and(imask,iar)
c
      if(inum.gt.0) then
        imask2=not(lshift(not(0),inum))
        ibits=or(lshift(ibits,inum),and(rshift(ibits,16-inum),imask2))
      else
        imask2=not(lshift(not(0),16+inum))
        ibits=or(lshift(ibits,16+inum),and(rshift(ibits,-inum),imask2))
      endif

      iishftc=or(and(not(imask),iar),ibits)
c
      return
      end
