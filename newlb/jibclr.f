      integer*4 function jibclr(iar,i)
      implicit none
      integer*4 iar,i,i1
      data i1/1/
c
      jibclr=and(iar,not(lshift(i1,i)))
c
      return
      end
