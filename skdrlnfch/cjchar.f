      function cjchar(iar,i)
C
C CJCHAR: returns the Ith character in hollerith array IAR
C
C  040506  ZMM  changed from character to character*1
C               changed type from integer to integer*2
C               removed trailing RETURN

      implicit none

      character*1 cjchar
! AEM 20041230 int*2 -> int      
      integer i
      integer*2 iar(*)
C
      call hol2char(iar,i,i,cjchar)

      end
