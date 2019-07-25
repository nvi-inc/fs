      logical function bitest(iar,i)
      implicit none
      integer*2 iar,i1
      integer i
      data i1/1/
c
      bitest=0.ne.and(iar,lshift(i1,i))
c
      return
      end
