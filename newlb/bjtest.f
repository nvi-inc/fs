      logical function bjtest(iar,i)
      implicit none
      integer*4 iar,i,i1
      data i1/1/
c
      bjtest=0.ne.and(iar,lshift(i1,i))
c
      return
      end
