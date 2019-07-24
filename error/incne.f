      subroutine incne(a,b,aux,npar,r,w)
C
      implicit none
      integer npar
      double precision a(1),b(1),aux(1),r,w
C
      integer nxpnt,i,j
C
      nxpnt=0
      do i=1,npar
        b(i)=b(i)+r*aux(i)*w
        do j=1,i
          a(nxpnt+j)=a(nxpnt+j)+aux(i)*aux(j)*w
        enddo
        nxpnt=nxpnt+i
      enddo
C
      return
      end
