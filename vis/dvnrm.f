C!DVNRM
      subroutine dvnrm(sc,v1,incr1,num)
      implicit none
      double precision sc,v1(1)
      integer incr1,num
C
C  DOUBLE PRECISION: SUM ABSOLUTE VALES
C
      integer i,index1
C
      if(num.le.0) return
      sc=0.0d0
C
      if(incr1.eq.1) then
        do i=1,num
          sc = sc + dabs(v1(i))
        enddo
      else
        index1=1
        do i=1,num
          sc = sc + dabs(v1(index1))
          index1=index1+incr1
        end do
      endif
C
      return
      end
