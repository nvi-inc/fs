      subroutine READG(IDCB,IERR,IBUF,ILEN)

C INPUT:
C  IDCB: Control Block
C  IERR: Error value
C  IBUF: Buffer for read

C OUTPUT:
C  ILEN: Length in characters of input

C OTHER:
C  CBUF: Character buffer used in input
C  trimlen: find number of characters read from file

      integer IDCB(1)
      integer IERR
      integer ILEN
      integer IBUF(1)
      character*256 CBUF
      integer trimlen,fmpreadstr
      integer err_chk
      integer loop

5     ilen = fmpreadstr(IDCB,IERR,CBUF)
      call char2low(cbuf)
      if ((IERR.ne.0).or.(ilen.eq.-1)) then
        ILEN=-1
        return
      endif
 
      IF((CBUF(1:1) .EQ. '*') .OR. (ILEN.EQ.0)) GOTO 5

      call char2hol(CBUF,IBUF,1,ILEN)
      call lower(ibuf,ilen)

      IERR=0

      return
      end
