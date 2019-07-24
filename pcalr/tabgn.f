      subroutine tabgn(itabl)
      implicit none
      integer itabl(256)
c
c  TABLE GENERATOR FOR SOFTWARE CORRELATOR  ARW 780916
c  COMPUTE TABLE OF # OF 1's IN EACH OF OCTAL NUMBERS 0-255 AND MAKE TABLE
c  converted to fortran weh 920119
c
      integer i,j,ib
c
      do i=0,255
        ib=0
        do j=0,7
          if(btest(i,j)) ib=ib+1
        enddo
        itabl(i+1)=ib
      enddo
c
      return
      end
