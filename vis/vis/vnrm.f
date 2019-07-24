C!VNRM
      subroutine vnrm(sc,v1,incr1,num)
      implicit none
      real*4 sc,v1(1)
      integer*2 incr1,num
C
C  SUM ABSOLUTE VALUES
C
      integer*2 i,index1
C
      if(num.le.0) return
      sc=0.0
C
      if(incr1.eq.1) then
        do i=1,num
          sc = sc + abs(v1(i))
        enddo
      else
        index1=1
        do i=1,num
          sc = sc + abs(v1(index1))
          index1=index1+incr1
        end do
      endif
C
      return
      end
