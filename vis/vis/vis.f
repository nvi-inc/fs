C!WSMY
      subroutine wsmy(sc,v1,incr1,v2,incr2,num)
      implicit none
      real*4 sc,v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  EMA SCALAR MULTIPLY
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = sc * v1(i)
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = sc * v1(jndex1)
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!DWSMY
      subroutine dwsmy(sc,v1,incr1,v2,incr2,num)
      implicit none
      real*8 sc,v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  DOUBLE PRECISION: EMA SCALAR MULTIPLY
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = sc * v1(i)
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = sc * v1(jndex1)
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!VSDV
      subroutine vsdv(sc,v1,incr1,v2,incr2,num)
      implicit none
      real*4 sc,v1(1),v2(1)
      integer*2 incr1,incr2,num
C
C  SCALAR DIVIDE
C
      integer*2 i,index1,index2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = sc / v1(i)
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          v2(index2) = sc / v1(index1)
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
C!DVSDV
      subroutine dvsdv(sc,v1,incr1,v2,incr2,num)
      implicit none
      real*8 sc,v1(1),v2(1)
      integer*2 incr1,incr2,num
C
C  DOUBLE PRECISION: SCALAR DIVIDE
C
      integer*2 i,index1,index2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = sc / v1(i)
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          v2(index2) = sc / v1(index1)
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
C!WSDV
      subroutine wsdv(sc,v1,incr1,v2,incr2,num)
      implicit none
      real*4 sc,v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  EMA SCALAR DIVIDE
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = sc / v1(i)
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = sc / v1(jndex1)
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!DWSDV
      subroutine dwsdv(sc,v1,incr1,v2,incr2,num)
      implicit none
      real*8 sc,v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  DOUBLE PRECISION: EMA SCALAR DIVIDE
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = sc / v1(i)
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = sc / v1(jndex1)
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!VABS
      subroutine vabs(v1,incr1,v2,incr2,num)
      implicit none
      real*4 v1(1),v2(1)
      integer*2 incr1,incr2,num
C
C  ABSOLUTE VALUE
C
      integer*2 i,index1,index2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = abs(v1(i))
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          v2(index2) = abs(v1(index1))
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
C!DVABS
      subroutine dvabs(v1,incr1,v2,incr2,num)
      implicit none
      real*8 v1(1),v2(1)
      integer*2 incr1,incr2,num
C
C  DOUBLE PRECISION: ABSOLUTE VALUE
C
      integer*2 i,index1,index2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = dabs(v1(i))
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          v2(index2) = dabs(v1(index1))
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
C!WABS
      subroutine wabs(v1,incr1,v2,incr2,num)
      implicit none
      real*4 v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  EMA ABSOLUTE VALUE
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = abs(v1(i))
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = abs(v1(jndex1))
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!DWABS
      subroutine dwabs(v1,incr1,v2,incr2,num)
      implicit none
      real*8 v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  DOUBLE PRECISION: EMA ABSOLUTE VALUE
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i) = dabs(v1(i))
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = dabs(v1(jndex1))
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!VSUM
      subroutine vsum(sc,v1,incr1,num)
      implicit none
      real*4 sc,v1(1)
      integer*2 incr1,num
C
C  SUM
C
      integer*2 i,index1
C
      if(num.le.0) return
      sc=0.0
C
      if(incr1.eq.1) then
        do i=1,num
          sc = sc + v1(i)
        enddo
      else
        index1=1
        do i=1,num
          sc = sc + v1(index1)
          index1=index1+incr1
        end do
      endif
C
      return
      end
C!DVSUM
      subroutine dvsum(sc,v1,incr1,num)
      implicit none
      real*8 sc,v1(1)
      integer*2 incr1,num
C
C  DOUBLE PRECISION: SUM
C
      integer*2 i,index1
C
      if(num.le.0) return
      sc=0.0d0
C
      if(incr1.eq.1) then
        do i=1,num
          sc = sc + v1(i)
        enddo
      else
        index1=1
        do i=1,num
          sc = sc + v1(index1)
          index1=index1+incr1
        end do
      endif
C
      return
      end
C!WSUM
      subroutine wsum(sc,v1,incr1,num)
      implicit none
      real*4 sc,v1(70000j)
      integer*2 incr1,num
C      EMA V1
C
C  EMA SUM
C
      integer*2 i
      integer*4 jndex1
C
      if(num.le.0) return
      sc=0.0
C
      if(incr1.eq.1) then
        do i=1,num
          sc = sc + v1(i)
        enddo
      else
        jndex1=1j
        do i=1,num
          sc = sc + v1(jndex1)
          jndex1=jndex1+incr1
        end do
      endif
C
      return
      end
C!DWSUM
      subroutine dwsum(sc,v1,incr1,num)
      implicit none
      real*8 sc,v1(70000j)
      integer*2 incr1,num
C      EMA V1
C
C  DOUBLE PRECISION: EMA SUM
C
      integer*2 i
      integer*4 jndex1
C
      if(num.le.0) return
      sc=0.0d0
C
      if(incr1.eq.1) then
        do i=1,num
          sc = sc + v1(i)
        enddo
      else
        jndex1=1j
        do i=1,num
          sc = sc + v1(jndex1)
          jndex1=jndex1+incr1
        end do
      endif
C
      return
      end
C!WNRM
      subroutine wnrm(sc,v1,incr1,num)
      implicit none
      real*4 sc,v1(70000j)
      integer*2 incr1,num
C      EMA V1
C
C  EMA SUM ABSOLUTE VALUES
C
      integer*2 i
      integer*4 jndex1
C
      if(num.le.0) return
      sc=0.0
C
      if(incr1.eq.1) then
        do i=1,num
          sc = sc + abs(v1(i))
        enddo
      else
        jndex1=1j
        do i=1,num
          sc = sc + abs(v1(jndex1))
          jndex1=jndex1+incr1
        end do
      endif
C
      return
      end
C!DWNRM
      subroutine dwnrm(sc,v1,incr1,num)
      implicit none
      real*8 sc,v1(70000j)
      integer*2 incr1,num
C      EMA V1
C
C  DOUBLE PRECISION: EMA SUM ABSOLUTE VALUES
C
      integer*2 i
      integer*4 jndex1
C
      if(num.le.0) return
      sc=0.0d0
C
      if(incr1.eq.1) then
        do i=1,num
          sc = sc + dabs(v1(i))
        enddo
      else
        jndex1=1j
        do i=1,num
          sc = sc + dabs(v1(jndex1))
          jndex1=jndex1+incr1
        end do
      endif
C
      return
      end
C!VMAX
      subroutine vmax(ind,v1,incr1,num)
      implicit none
      real*4 v1(1)
      integer*2 ind,incr1,num
C
C  MAXIMUM VALUE
C
      integer*2 i,index1
      real*4 maxval,temp
C
      if(num.le.0) return
      ind=1
      index1=1
      maxval=v1(index1)
C
      if(incr1.eq.1) then
        do i=2,num
          temp=v1(i)
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        enddo
      else
        do i=2,num
          index1=index1+incr1
          temp=v1(index1)
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        end do
      endif
C
      return
      end
C!DVMAX
      subroutine dvmax(ind,v1,incr1,num)
      implicit none
      real*8 v1(1)
      integer*2 ind,incr1,num
C
C  DOUBLE PRECISION: MAXIMUM VALUE
C
      integer*2 i,index1
      real*8 maxval,temp
C
      if(num.le.0) return
      ind=1
      index1=1
      maxval=v1(index1)
C
      if(incr1.eq.1) then
        do i=2,num
          temp=v1(i)
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        enddo
      else
        do i=2,num
          index1=index1+incr1
          temp=v1(index1)
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        end do
      endif
C
      return
      end
C!WMAX
      subroutine wmax(ind,v1,incr1,num)
      implicit none
      real*4 v1(70000j)
      integer*2 ind,incr1,num
C      EMA V1
C
C  EMA MAXIMUM VALUE
C
      integer*2 i
      integer*4 jndex1
      real*4 maxval,temp
C
      if(num.le.0) return
      ind=1
      jndex1=1j
      maxval=v1(jndex1)
C
      if(incr1.eq.1) then
        do i=2,num
          temp=v1(i)
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        enddo
      else
        do i=2,num
          jndex1=jndex1+incr1
          temp=v1(jndex1)
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        end do
      endif
C
      return
      end
C!DWMAX
      subroutine dwmax(ind,v1,incr1,num)
      implicit none
      real*8 v1(70000j)
      integer*2 ind,incr1,num
C      EMA V1
C
C  DOUBLE PRECISION: EMA MAXIMUM VALUE
C
      integer*2 i
      integer*4 jndex1
      real*8 maxval,temp
C
      if(num.le.0) return
      ind=1
      jndex1=1j
      maxval=v1(jndex1)
C
      if(incr1.eq.1) then
        do i=2,num
          temp=v1(i)
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        enddo
      else
        do i=2,num
          jndex1=jndex1+incr1
          temp=v1(jndex1)
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        end do
      endif
C
      return
      end
C!VMIN
      subroutine vmin(ind,v1,incr1,num)
      implicit none
      real*4 v1(1)
      integer*2 ind,incr1,num
C
C  MINIMUM VALUE
C
      integer*2 i,index1
      real*4 minval,temp
C
      if(num.le.0) return
      ind=1
      index1=1
      minval=v1(index1)
C
      if(incr1.eq.1) then
        do i=2,num
          temp=v1(i)
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        enddo
      else
        do i=2,num
          index1=index1+incr1
          temp=v1(index1)
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        end do
      endif
C
      return
      end
C!DVMIN
      subroutine dvmin(ind,v1,incr1,num)
      implicit none
      real*8 v1(1)
      integer*2 ind,incr1,num
C
C  DOUBLE PRECISION: MINIMUM VALUE
C
      integer*2 i,index1
      real*8 minval,temp
C
      if(num.le.0) return
      ind=1
      index1=1
      minval=v1(index1)
C
      if(incr1.eq.1) then
        do i=2,num
          temp=v1(i)
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        enddo
      else
        do i=2,num
          index1=index1+incr1
          temp=v1(index1)
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        end do
      endif
C
      return
      end
C!WMIN
      subroutine wmin(ind,v1,incr1,num)
      implicit none
      real*4 v1(70000j)
      integer*2 ind,incr1,num
C      EMA V1
C
C  EMA MINIMUM VALUE
C
      integer*2 i
      integer*4 jndex1
      real*4 minval,temp
C
      if(num.le.0) return
      ind=1
      jndex1=1j
      minval=v1(jndex1)
C
      if(incr1.eq.1) then
        do i=2,num
          temp=v1(i)
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        enddo
      else
        do i=2,num
          jndex1=jndex1+incr1
          temp=v1(jndex1)
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        end do
      endif
C
      return
      end
C!DWMIN
      subroutine dwmin(ind,v1,incr1,num)
      implicit none
      real*8 v1(70000j)
      integer*2 ind,incr1,num
C      EMA V1
C
C  DOUBLE PRECISION: EMA MINIMUM VALUE
C
      integer*2 i
      integer*4 jndex1
      real*8 minval,temp
C
      if(num.le.0) return
      ind=1
      jndex1=1j
      minval=v1(jndex1)
C
      if(incr1.eq.1) then
        do i=2,num
          temp=v1(i)
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        enddo
      else
        do i=2,num
          jndex1=jndex1+incr1
          temp=v1(jndex1)
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        end do
      endif
C
      return
      end
C!VMAB
      subroutine vmab(ind,v1,incr1,num)
      implicit none
      real*4 v1(1)
      integer*2 ind,incr1,num
C
C  MAXIMUM ABSOLUTE VALUE
C
      integer*2 i,index1
      real*4 maxval,temp
C
      if(num.le.0) return
      ind=1
      index1=1
      maxval=abs(v1(index1))
C
      if(incr1.eq.1) then
        do i=2,num
          temp=abs(v1(i))
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        enddo
      else
        do i=2,num
          index1=index1+incr1
          temp=abs(v1(index1))
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        end do
      endif
C
      return
      end
C!DVMAB
      subroutine dvmab(ind,v1,incr1,num)
      implicit none
      real*8 v1(1)
      integer*2 ind,incr1,num
C
C  DOUBLE PRECISION: MAXIMUM ABSOLUTE VALUE
C
      integer*2 i,index1
      real*8 maxval,temp
C
      if(num.le.0) return
      ind=1
      index1=1
      maxval=dabs(v1(index1))
C
      if(incr1.eq.1) then
        do i=2,num
          temp=dabs(v1(i))
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        enddo
      else
        do i=2,num
          index1=index1+incr1
          temp=dabs(v1(index1))
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        end do
      endif
C
      return
      end
C!WMAB
      subroutine wmab(ind,v1,incr1,num)
      implicit none
      real*4 v1(70000j)
      integer*2 ind,incr1,num
C      EMA V1
C
C  EMA MAXIMUM ABSOLUTE VALUE
C
      integer*2 i
      integer*4 jndex1
      real*4 maxval,temp
C
      if(num.le.0) return
      ind=1
      jndex1=1j
      maxval=abs(v1(jndex1))
C
      if(incr1.eq.1) then
        do i=2,num
          temp=abs(v1(i))
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        enddo
      else
        do i=2,num
          jndex1=jndex1+incr1
          temp=abs(v1(jndex1))
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        end do
      endif
C
      return
      end
C!DWMAB
      subroutine dwmab(ind,v1,incr1,num)
      implicit none
      real*8 v1(70000j)
      integer*2 ind,incr1,num
C      EMA V1
C
C  DOUBLE PRECISION: EMA MAXIMUM ABSOLUTE VALUE
C
      integer*2 i
      integer*4 jndex1
      real*8 maxval,temp
C
      if(num.le.0) return
      ind=1
      jndex1=1j
      maxval=dabs(v1(jndex1))
C
      if(incr1.eq.1) then
        do i=2,num
          temp=dabs(v1(i))
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        enddo
      else
        do i=2,num
          jndex1=jndex1+incr1
          temp=dabs(v1(jndex1))
          if(temp.gt.maxval) then
            ind=i
            maxval=temp
          endif
        end do
      endif
C
      return
      end
C!VMIB
      subroutine vmib(ind,v1,incr1,num)
      implicit none
      real*4 v1(1)
      integer*2 ind,incr1,num
C
C  MINIMUM ABSOLUTE VALUE
C
      integer*2 i,index1
      real*4 minval,temp
C
      if(num.le.0) return
      ind=1
      index1=1
      minval=abs(v1(index1))
C
      if(incr1.eq.1) then
        do i=2,num
          temp=abs(v1(i))
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        enddo
      else
        do i=2,num
          index1=index1+incr1
          temp=abs(v1(index1))
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        end do
      endif
C
      return
      end
C!DVMIB
      subroutine dvmib(ind,v1,incr1,num)
      implicit none
      real*8 v1(1)
      integer*2 ind,incr1,num
C
C  DOUBLE PRECISION: MINIMUM ABSOLUTE VALUE
C
      integer*2 i,index1
      real*8 minval,temp
C
      if(num.le.0) return
      ind=1
      index1=1
      minval=dabs(v1(index1))
C
      if(incr1.eq.1) then
        do i=2,num
          temp=dabs(v1(i))
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        enddo
      else
        do i=2,num
          index1=index1+incr1
          temp=dabs(v1(index1))
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        end do
      endif
C
      return
      end
C!WMIB
      subroutine wmib(ind,v1,incr1,num)
      implicit none
      real*4 v1(70000j)
      integer*2 ind,incr1,num
C      EMA V1
C
C  EMA MINIMUM ABSOLUTE VALUE
C
      integer*2 i
      integer*4 jndex1
      real*4 minval,temp
C
      if(num.le.0) return
      ind=1
      jndex1=1j
      minval=abs(v1(jndex1))
C
      if(incr1.eq.1) then
        do i=2,num
          temp=abs(v1(i))
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        enddo
      else
        do i=2,num
          jndex1=jndex1+incr1
          temp=abs(v1(jndex1))
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        end do
      endif
C
      return
      end
C!DWMIB
      subroutine dwmib(ind,v1,incr1,num)
      implicit none
      real*8 v1(70000j)
      integer*2 ind,incr1,num
C      EMA V1
C
C  DOUBLE PRECISION: EMA MINIMUM ABSOLUTE VALUE
C
      integer*2 i
      integer*4 jndex1
      real*8 minval,temp
C
      if(num.le.0) return
      ind=1
      jndex1=1j
      minval=dabs(v1(jndex1))
C
      if(incr1.eq.1) then
        do i=2,num
          temp=dabs(v1(i))
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        enddo
      else
        do i=2,num
          jndex1=jndex1+incr1
          temp=dabs(v1(jndex1))
          if(temp.lt.minval) then
            ind=i
            minval=temp
          endif
        end do
      endif
C
      return
      end
C!VMOV
      subroutine vmov(v1,incr1,v2,incr2,num)
      implicit none
      real*4 v1(1),v2(1)
      integer*2 incr1,incr2,num
C
C  MOVE
C
      integer*2 i,index1,index2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.-1.and.incr2.eq.-1) then
        do i=1,2-num,-1
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.0.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(1)
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          v2(index2) = v1(index1)
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
C!DVMOV
      subroutine dvmov(v1,incr1,v2,incr2,num)
      implicit none
      real*8 v1(1),v2(1)
      integer*2 incr1,incr2,num
C
C  DOUBLE PRECISION: MOVE
C
      integer*2 i,index1,index2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.-1.and.incr2.eq.-1) then
        do i=1,2-num,-1
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.0.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(1)
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          v2(index2) = v1(index1)
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
C!WMOV
      subroutine wmov(v1,incr1,v2,incr2,num)
      implicit none
      real*4 v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  EMA MOVE
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.-1.and.incr2.eq.-1) then
        do i=1,2-num,-1
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.0.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(1)
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = v1(jndex1)
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!DWMOV
      subroutine dwmov(v1,incr1,v2,incr2,num)
      implicit none
      real*8 v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  DOUBLE PRECISION: EMA MOVE
C
      integer*2 i
      integer*4 jndex1,jndex2
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.-1.and.incr2.eq.-1) then
        do i=1,2-num,-1
          v2(i)=v1(i)
        enddo
      else if(incr1.eq.0.and.incr2.eq.1) then
        do i=1,num
          v2(i)=v1(1)
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          v2(jndex2) = v1(jndex1)
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!VSWP
      subroutine vswp(v1,incr1,v2,incr2,num)
      implicit none
      real*4 v1(1),v2(1)
      integer*2 incr1,incr2,num
C
C  SWAP
C
      integer*2 i,index1,index2
      real*4 temp
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          temp = v1(i)
          v1(i)= v2(i)
          v2(i)= temp
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          temp = v1(index1)
          v1(index2) = v2(index1)
          v2(index2) = temp
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
C!DVSWP
      subroutine dvswp(v1,incr1,v2,incr2,num)
      implicit none
      real*8 v1(1),v2(1)
      integer*2 incr1,incr2,num
C
C  DOUBLE PRECISION: SWAP
C
      integer*2 i,index1,index2
      real*8 temp
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          temp = v1(i)
          v1(i)= v2(i)
          v2(i)= temp
        enddo
      else
        index1=1
        index2=1
        do i=1,num
          temp = v1(index1)
          v1(index2) = v2(index1)
          v2(index2) = temp
          index1=index1+incr1
          index2=index2+incr2
        end do
      endif
C
      return
      end
C!WSWP
      subroutine wswp(v1,incr1,v2,incr2,num)
      implicit none
      real*4 v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  EMA SWAP
C
      integer*2 i
      integer*4 jndex1,jndex2
      real*4 temp
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          temp = v1(i)
          v1(i)= v2(i)
          v2(i)= temp
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          temp = v1(jndex1)
          v1(jndex2) = v2(jndex1)
          v2(jndex2) = temp
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
C!DWSWP
      subroutine dwswp(v1,incr1,v2,incr2,num)
      implicit none
      real*8 v1(70000j),v2(70000j)
      integer*2 incr1,incr2,num
C      EMA V1,V2
C
C  DOUBLE PRECISION: EMA SWAP
C
      integer*2 i
      integer*4 jndex1,jndex2
      real*8 temp
C
      if(incr1.eq.1.and.incr2.eq.1) then
        do i=1,num
          temp = v1(i)
          v1(i)= v2(i)
          v2(i)= temp
        enddo
      else
        jndex1=1j
        jndex2=1j
        do i=1,num
          temp = v1(jndex1)
          v1(jndex2) = v2(jndex1)
          v2(jndex2) = temp
          jndex1=jndex1+incr1
          jndex2=jndex2+incr2
        end do
      endif
C
      return
      end
