      integer*2 function iishft(iar,inum)
      implicit none
      integer*2 iar
      integer inum
c
      integer*2 imask
c
      if(inum.ge.0) then
        iishft=lshift(iar,inum)
      else
        imask=not(lshift(not(0),16+inum))
        iishft=and(rshift(iar,-inum),imask)
      endif
c
      return
      end
