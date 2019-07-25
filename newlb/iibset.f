      integer*2 function iibset(iar,i)
      implicit none
      integer*2 iar,i1
      integer i
      data i1/1/
c
      iibset=or(iar,lshift(i1,i))
c
      return
      end
