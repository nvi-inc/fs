      subroutine reads(idcb,ibuf,iblen,nchar,ierr)
C
C     READS - reads the next line from the schedule file
C
C
C  INPUT VARIABLES:
C
      dimension idcb(1)
C       DCB for schedule file
C     IBLEN - length of IBUF in words
C
C
C  OUTPUT VARIABLES:
C
      integer*2 ibuf(1)
C       buffer with next schedule line
C     NCHAR - number of characters in IBUF
C     IERR  - error return, FMP codes
C
C
C  LOCAL VARIABLES:
C
C     IL  - length of buffer read
      character*512 ibc
      integer*2 ib(256)
      integer fblnk,fmpreadstr
      equivalence (ib,ibc)
C
C
C  INITIALIZED VARIABLES:
C
C
C  PROGRAMMER: NRV
C  LAST MODIFIED:  CREATED 790912
C
C
C     1. Simple read from schedule file, and get number of characters.
C
      nchar = 0
100   len = fmpreadstr(idcb,ierr,ibc)
      if (ierr.lt.0.or.len.lt.0) goto 900
      if (len.eq.0) goto 100
      nchar = iflch(ib,512)
      if (nchar.eq.0) goto 100
      id = ichmv(ibuf,1,ib,1,nchar)
      nchar=fblnk(ibuf,1,nchar)
      return
900   call fmpclose(idcb,ierr)
      return
      end
