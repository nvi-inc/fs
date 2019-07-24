      subroutine F_WRITESTRING(IDCB,IERR,CBUF,ILEN)

C INPUT:
C  IDCB: Control Block
C  IERR: Error value
C  CBUF: Character buffer to be written

C OUTPUT:
C  ILEN: Length in characters of input

C  trimlen: find number of characters read from file

      integer IDCB
      integer IERR
      integer ILEN
      character*(*) CBUF
      integer trimlen

5     write(IDCB,10,IOSTAT=IERR) CBUF
10    format(A)
      ILEN=trimlen(CBUF)
C If an error reset ilen to -1 since length is unwritten
      if (IERR.ne.0) then
        ILEN=-1
        return
      else
        return
      end if

      end
