      character function cjchar(iar,i)
C
C CJCHAR: returns the Ith character in hollerith array IAR
C
      implicit none
      integer iar(1),i
C
      call hol2char(iar,i,i,cjchar)

      return
      end
