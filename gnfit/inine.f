      subroutine inine(a,b,npar)
C
      implicit none
      integer npar
      double precision a(1),b(1)
C
      integer nxpnt,i,j
C
      nxpnt=0
      do i=1,npar
        b(i)=0.0d0
        do j=1,i
          a(nxpnt+j)=0.0d0
        enddo
        nxpnt=nxpnt+i
      enddo
C
      return
      end
