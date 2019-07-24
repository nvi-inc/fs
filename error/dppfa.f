      subroutine dppfa(a,n,info)
      implicit none
      integer n,info
      double precision a(1)
C
C CHOLESKY FACTORIZATION OF A SOLVE FORMAT MATRIX
C
C DOUBLE PRECESION VERSION OF LINPACK SPPFA ROUTINE WITH
C DIRECT CALLS TO THE HP VECTOR INSTRUCTION SET AND
C
      integer j,k
      integer jj,kj,kk
      double precision s,t
C
      jj=0
      do j=1,n
        s=0.0d0
        kj=jj
        kk=0
        do k=1,j-1
          kj=kj+1
          t=0.0d0
          call dvdot(t,a(kk+1),1,a(jj+1),1,k-1)
          t=a(kj)-t
          kk=kk+k
          t=t/a(kk)
          a(kj)=t
          s=s+t*t
        enddo
        jj=jj+j
        s=a(jj)-s
        if(s.le.0.0) then
          info=j
          return
        endif
        a(jj)=dsqrt(s)
      enddo
      info=0
C
      return
      end
