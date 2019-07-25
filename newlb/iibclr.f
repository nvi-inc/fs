      integer*2 function iibclr(iar,i)
      implicit none
      integer*2 iar,i1
      integer i
      data i1/1/
c
      iibclr=and(iar,not(lshift(i1,i)))
c
      return
      end
