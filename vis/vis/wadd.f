C!WADD
      subroutine wadd(v1,incr1,v2,incr2,v3,incr3,num)
      implicit none
      real*4 v1(70000j),v2(70000j),v3(70000j)
      integer*2 incr1,incr2,incr3,num
C      EMA V1,V2,V3
C
C  EMA ADD
C
      integer*2 i
      integer*4 jndex1,jndex2,jndex3
C
      if(incr1.eq.1.and.incr2.eq.1.and.incr3.eq.1) then
        do i=1,num
          v3(i) = v1(i) + v2(i)
        enddo
      else
        jndex1=1j
        jndex2=1j
        jndex3=1j
        do i=1,num
          v3(jndex3) = v1(jndex1) + v2(jndex2)
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
          jndex3=jndex3+incr3
        end do
      endif
C
      return
      end
