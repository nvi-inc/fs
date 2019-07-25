      integer*4 function jibset(iar,i)
      implicit none
      integer*4 iar,i,i1
      data i1/1/
c
      jibset=or(iar,lshift(i1,i))
c
      return
      end
