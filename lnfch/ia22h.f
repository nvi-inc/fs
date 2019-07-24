      function ia22h(iword) 
C 
C    IA22H converts a 2-character ASCII word into a decimal number
C          between 0 and 255
C 
      integer*2 iword
      dimension ival(23)
C               - lookup table of hex values
      data ival/0,1,2,3,4,5,6,7,8,9,7*0,10,11,12,13,14,15/
C 
C     1. Get the index into lookup table by subtracting o'57' from
C       each character.  If index is not within range set to 0. 
C 
      ind1 = jchar(iword,1)
      if (ind1.ge.o'141'.and.ind1.le.o'146') ind1 = ind1 - o'40'
C          if lower case a ... f, change to upper
      ind2 = jchar(iword,2)
      if (ind2.ge.o'141'.and.ind2.le.o'146') ind2 = ind2 - o'40'
C          if lower case a ... f, change to upper
      ind1 = ind1 - o'57' 
      ind2 = ind2 - o'57' 
      ia22h = -1
      if (ind1.lt.1.or.ind1.gt.23.or.ind2.lt.1.or.ind2.gt.23) return
      ia22h = ival(ind1)*16 + ival(ind2)

      return
      end 
