C!DVWMV
      subroutine dvwmv(v1,incr1,v2,incr2,num)
      implicit none
      real*8 v1(1),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V2
C
C  DOUBLE PRECISION: MOVE LOCAL MEMORY TO EMA
C
      integer*2 i,index1
      integer*4 jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.0.and.incr2.eq.1) then
         do i=1,num
           v2(i)=v1(1)
         enddo
      else
        index1=1
        jndex2=1j
        do i=1,num
          v2(jndex2) = v1(index1)
          index1=index1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
