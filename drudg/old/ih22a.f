C@IH22A
      integer*2 FUNCTION IH22A(IBYTE)
C
C     ROUTINE TO CONVERT LOWER 8 BITS OF IBYTE TO A PRINTABLE A2 HEX.
C     ITAB changed to integer*2 by P. Ryan
C
      implicit none
      integer*2 ibyte,jchar
      INTEGER*2 ITAB (  8)
      CHARACTER*16 ITAB_CHR
      EQUIVALENCE(ITAB,ITAB_CHR)

      DATA ITAB_CHR /'0123456789ABCDEF'/
C
      IH22A=JCHAR(ITAB,IAND(IBYTE,o'360')/o'20'+1)*o'400'+
     .      JCHAR(ITAB,IAND(IBYTE,o'17')+1)
      RETURN
      END
