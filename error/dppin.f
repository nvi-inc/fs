      subroutine dppin(a,n)
      implicit none
      double precision a(1)
      integer n
C
C CALCULATE INVERSE FROM A CHOLESKY FACTORIZATION OF A SOLVE FORMAT MATRIX
C
C DOUBLE PRECISION VERSION OF LINPACK SPPDI ROUTINE WITH
C DIRECT CALLS TO THE HP VECTOR INSTRUCTION SET AND
C ONLY THE INVERSION PART OF THE ORIGINAL LINPACK IS HERE
C
      integer j,k
      integer k1,kk,j1,kj,jj
      double precision t
C
      kk=0
      do k=1,n
        k1=kk+1
        kk=kk+k
        a(kk)=1.0d0/a(kk)
        t=-a(kk)
        call dvsmy(t,a(k1),1,a(k1),1,k-1)
        j1=kk+1
        kj=kk+k
        do j=k+1,n
          t=a(kj)
          a(kj)=0.0d0
          call dvpiv(t,a(k1),1,a(j1),1,a(j1),1,k)
          j1=j1+j
          kj=kj+j
        enddo
      enddo
C
      jj=0
      do j=1,n
        j1=jj+1
        jj=jj+j
        k1=1
        kj=j1
        do k=1,j-1
          t=a(kj)
          call dvpiv(t,a(j1),1,a(k1),1,a(k1),1,k)
          k1=k1+k
          kj=kj+1
        enddo
        t=a(jj)
        call dvsmy(t,a(j1),1,a(j1),1,j) 
      enddo 
C 
      return
      end 
