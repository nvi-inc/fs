      integer function i1bit(iword)
      implicit none
      integer*2 iword
c
c  count the 1 bits in a word
c
      integer j
      logical bitest
c
      i1bit=0
      do j=0,15
        if(bitest(iword,j)) i1bit=i1bit+1
      enddo
c
      return
      end
