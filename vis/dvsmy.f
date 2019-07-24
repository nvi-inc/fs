C!DVSMY
      subroutine dvsmy(sc,v1,incr1,v2,incr2,num)
      implicit none
      double precision sc,v1(1),v2(1)
      integer incr1,incr2,num
C
C  DOUBLE PRECISION: SCALAR MULTIPLY
C
      integer i,index1,index2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = sc * v1(i)
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          v2(index2) = sc * v1(index1)
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
