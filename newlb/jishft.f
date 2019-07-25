      integer*4 function jishft(iar,inum)
      implicit none
      integer*4 iar
      integer inum
c
      integer*4 imask
c
      if(inum.ge.0) then
        jishft=lshift(iar,inum)
      else
        imask=not(lshift(not(0),32+inum))
        jishft=and(rshift(iar,-inum),imask)
      endif
c
      return
      end
