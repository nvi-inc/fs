C!WVMOV
      subroutine wvmov(v1,incr1,v2,incr2,num)
      implicit none
      real*4 v1(70000j),v2(1)
      integer*2 incr1,incr2,num
C      EMA V1
C
C  MOVE EMA TO NORMAL MEMORY
C
      integer*2 i,index2
      integer*4 jndex1
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(i)
        enddo
      else
        jndex1=1j
        index2=1
        do i=1,num
          v2(index2) = v1(jndex1)
          jndex1=jndex1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
