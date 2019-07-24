      subroutine F_READSTRING(IDCB,IERR,CBUF,ILEN)

C INPUT:
C  IDCB: Control Block
C  IERR: Error value

C OUTPUT:
C  ILEN: Length in characters of input

C OTHER:
C  CBUF: Character buffer used in input
C  trimlen: find number of characters read from file

      integer IDCB
      integer IERR
      integer ILEN
      character*(*) CBUF
      integer trimlen

C Read in the buffer
5     read(IDCB,10,end=20,IOSTAT=IERR) CBUF
10    format(A)
      ILEN=trimlen(CBUF)
C If an error reset ilen to -1 since length is unknown
      if (IERR.ne.0) then
        ILEN=-1
        return
      else
        return
      end if
20    ILEN=-1
      IERR=0

      return
      end
