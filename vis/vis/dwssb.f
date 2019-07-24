C!DWSSB
      subroutine dwssb(sc,v1,incr1,v2,incr2,num)
      implicit none
      real*8 sc,v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  DOUBLE PRECISION: EMA SCALAR SUBTRACT
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = sc - v1(i)
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = sc - v1(jndex1)
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
