      subroutine opnpf(lprc,idcb,ibuf,iblen,lproc,maxpr,nproc,ierr,old)
C     !OPEN PROC FILE AND MAKE DIRECTORY C#870115:04:19#
C
C     OPNPF opens the named procedure file and reads through
C     it, making a directory of the entries.
C
C     DATE   WHO CHANGES
C     810906 NRV CREATED
C     890509 MWH Modified to use CI files
c
      include '../include/params.i'
C
C  INPUT:
C
C     LPRC - the file name
      character*(*) lprc
C     IDCB - DCB for opening the file
C     IBUF - a buffer to use for reading
C     IBLEN - the length of IBUF in words
C     MAXPR - maximum number of entries in LPROC
C     OLD - 'N' if new procedure library, 'O' if old
      integer idcb(1)
      character*(*) old
C
C  OUTPUT:
C
C     LPROC - the procedure directory information
C     NPROC - number of procedures in this file
      integer*2 lproc(10,1)
C
C  LOCAL:
C
C     IERR - error return from FMP routines
C     ICH - character counter
C     LNAMEF - full file name
      integer*4 irec,ioff
      integer fmpposition,fmpreadstr,fmpsetpos,fmpwritestr
      integer trimlen
      character*28 lnamef
      character*80 ibc
      integer*2 ib(40)
      equivalence (ib,ibc)
C
C
C     1. First try to open the file.
C     The file is opened non-exclusively and in update mode.
C
      nch = trimlen(lprc)
      lnamef = FS_ROOT//'/proc/' // lprc(1:nch) // '.prc'
      call fmpopen(idcb,lnamef,ierr,'r+',id)
      if (ierr.lt.0) return
C
C     2. The file is opened.  Read through all lines.
C     If we encounter DEFINE, then execute next section.
C
      nproc = 0
210   ilen = fmpreadstr(idcb,ierr,ibc)
      call char2low(ibc)
      if (ilen.le.0) goto 900
      if (ierr.lt.0) goto 990
      if (ibc(1:6).eq.'define') then
C
C     3. Fill up LPROC with the information on this file location.
C
        if (nproc+1.gt.maxpr) then
          call logit7(0,0,0,1,-126,2hbo,maxpr)
          goto 990
        endif
        nproc = nproc + 1
        id = fmpposition(idcb,ierr,irec,ioff)
        do j=1,6
          lproc(j,nproc)=ib(4+j)
        enddo
        irectmp = irec - ilen - 1
        lproc(8,nproc) = irectmp
        lproc(10,nproc) = ioff
        if (old.eq.'n') then
          irec = irectmp
          idum = fmpsetpos(idcb,ierr,irec,-irec)
          ibc(23:34)='00000000000x'
          ilen = fmpwritestr(idcb,ierr,ibc(:ilen))
          irec= irec + ilen + 1
          idum = fmpsetpos(idcb,ierr,irec,-irec)
          if(ierr.lt.0) goto 900
        endif
      endif
      goto 210
C
C     9. Normal ending because EOF is reached.
C
900   ierr = 0
C
990   idum = fmpsetpos(idcb,ierr,0,id)
      return
      end
