      subroutine dppsl(a,b,n)
      implicit none
      integer n
      double precision a(1),b(1)
C
C SOLVE FROM A CHOLESKY FACTORIZATION OF A SOLVE FORMAT MATRIX
C
C DOUBLE PRECESION VERSION OF LINPACK SPPSL ROUTINE WITH
C DIRECT CALLS TO THE HP VECTOR INSTRUCTION SET
C
      integer k
      integer kk
      double precision t
C
      kk=0
      do k=1,n
        t=0.0d0
        call dvdot(t,a(kk+1),1,b,1,k-1)
        kk=kk+k
        b(k)=(b(k)-t)/a(kk)
      enddo
C
      do k=n,1,-1
        b(k)=b(k)/a(kk)
        kk=kk-k
        t=-b(k)
        call dvpiv(t,a(kk+1),1,b,1,b,1,k-1)
      enddo
C
      return
      end
