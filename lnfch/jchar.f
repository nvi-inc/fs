      integer function jchar(iar,i)
C
C JCHAR: returns the Ith character (IN LOWER BIT) in hollerith array IAR
C 900807 MODIFIED TO FIT DOS BIT STORAGE (LOWER/UPPER) AS OPPOSED
C TO UNIX EQUIV. (UPPER/LOWER)

      implicit none
      integer*2 iar(1)
      integer F2,i
      data F2/Z'FF'/
C
      jchar=iar((i+1)/2)

c original coding
c      IF(MOD(I,2).EQ.1) JCHAR=ISHFT(JCHAR,-8)
C      JCHAR=IAND(JCHAR,F2)
c 900808 put char in DOS higher (RIGHT) bit - lower position
C storage: odd position on right bit, even position on left bit

      if(mod(i,2).eq.0) jchar=ishft(jchar,-8)
      jchar=iand(jchar,F2)

      return
      end
