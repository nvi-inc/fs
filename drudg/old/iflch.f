C@IFLCH
C
      integer FUNCTION IFLCH(IBUF,ILEN)
C
C     IFLCH - finds the last character in the buffer
C             by lopping off trailing blanks
C
      implicit none
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C     ILEN - length of IBUF in CHARACTERS
C
C  OUTPUT:
C     IFLCH - number of characters in IBUF
C
C  LOCAL:
      integer i,nb,jchar
      integer oblank
      data oblank /O'40'/
C
C  PROGRAMMER:  NRV
C  LAST MODIFIED 800825
C  930225 nrv implicit none
C
C
C     1. Step backwards through the buffer, deleting any
C     blanks as we come to them.
C
      NB = 0
      DO 100 I=ILEN,1,-1
        IF (JCHAR(IBUF,I).EQ.oblank) NB = NB + 1
        IF (JCHAR(IBUF,I).NE.oblank) GOTO 101
100     CONTINUE
101   IFLCH = ILEN - NB
      RETURN
      END
