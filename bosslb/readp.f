      subroutine readp(idcbp1,idcbp2,istack,lstack,lproc1,lproc2,kbreak,
     .ibuf,iblen,nchar,lprocn,lparm,nparm,ierr)
C
C     READP - reads the next line from a procedure
C     The stack is popped as necessary.
C
C     DATE   WHO CHANGES
C     810907 NRV Modified for procedure files
C     840217 MWH Modified stack structure
C
C     INPUT VARIABLES:
C
C     IDCBP1,2 - DCBs for the two proc files
C     ISTACK - Stack for popping next procedure
C     LSTACK - Stack for popping next parameters
C     LPROC1,2 - procedure directories
C     KBREAK - true if we are to end the current procedure now
C               We set this to false after doing our thing.
C     IBUF - buffer for reading the command
C     IBLEN  - length of IBUF in words
      dimension idcbp1(1),idcbp2(1)
      dimension istack(1),lstack(1)
      integer*4 lproc1(4,1),lproc2(4,1)
      integer*2 ibuf(1)
      logical kbreak
C
C     OUTPUT VARIABLES:
C
C     NCHAR - Number of characters in the command in IBUF
C     LPROCN - the full procedure name - this is unchanged if
C              no new procedure is popped
C     LPARM - parameter string for this procedure
C     NPARM - number of characters in LPARM
C     IERR  - error return, FMP error from READF
      dimension lparm(1),lprocn(1)
C
C
C  LOCAL VARIABLES:
C
C     INDEXP - index of the procedure
C     IREC - location informtion for current line of procedure
C     IL - length of record read from file
      integer*4 irecl,id
      integer fblnk,fmpposition,fmpreadstr,fmpsetpos
      dimension irec(4)
      character*512 ibc
      integer*2 ib(256)
      equivalence (ib,ibc)
C
C  INITIALIZED VARIABLES:
C
C
C
C     1. First try simply reading the next line from the DCB.
C     If that works, then we are done.
C
100   nchar = 0
      call prget(istack,irec,2,ierr)
      if (ierr.lt.0) goto 800
      indexp = irec(2)
      irecl = irec(1)
      if(indexp.gt.0)id = fmpsetpos(idcbp1,ierr,irecl,-irecl)
      if(indexp.lt.0)id = fmpsetpos(idcbp2,ierr,irecl,-irecl)
      if(ierr.lt.0)goto 800
      if (indexp.gt.0) ilen = fmpreadstr(idcbp1,ierr,ibc)
      if (indexp.lt.0) ilen = fmpreadstr(idcbp2,ierr,ibc)
      call char2low(ibc)
      if (ierr.lt.0) goto 800
      if (ilen.lt.0.or.ibc(1:6).eq.'enddef'.or.ibc(1:6).eq.'define')
     .   goto 200
C                     These are the conditions for end-of-procedure
C
C     Get location of next record of the procedure and put into stack
C
      if(indexp.gt.0)id = fmpposition(idcbp1,ierr,irecl,id)
      if(indexp.lt.0)id = fmpposition(idcbp2,ierr,irecl,id)
      irec(1) = irecl
      if(ierr.lt.0)goto 800
      indx = istack(2) - 2
      istack(indx+1) = irec(1)
      nchar = iflch(ib,512)
      if (ibc.eq.' ') goto 100
      nchar=fblnk(ib,1,nchar)
      call lower(ib,nchar)
      id = ichmv(ibuf,1,ib,1,nchar)
      call prpop(lstack,nparm,1,ierr)
C                     Pop up the # parm ...
      if (nparm.ne.0) call prget(lstack,lparm,(nparm+1)/2,ierr)
C                     Get the parameters for this procedure
      call prput(lstack,nparm,1,ierr)
C                     Re-place on stack
      goto 900
C
C
C     2. This procedure is used up.
C     Pop the index of the current proc to get rid of it.
C     Pop the last line of the previous procedure.
C     Also pop up the old parameters, if any.
C
200   continue
      kbreak = .false.
      call prpop(istack,indexp,1,ierr)
C                     This is the index of the just-completed procedure
      call prpop(istack,irec,1,ierr)
C                     This is the location info for the previous procedure
      call prpop(lstack,nparm,1,ierr)
      if (nparm.ne.0) call prpop(lstack,lparm,(nparm+1)/2,ierr)
      if (istack(2).eq.2) goto 900
C                     This is the end of the stack
C
C
C     3. Re-position to the new procedure, then go back and try reading again.
C     If the next procedure is used up too, continue to pop up
C     the stacked names until we find one with more records.
C
      call prget(istack,indexp,1,ierr)
      irecl = lproc1(4,indexp)
      if (indexp.lt.0) goto 320
      id = fmpsetpos(idcbp1,ierr,irecl,-irecl)
      if (ierr.lt.0) goto 800
      ilen = fmpreadstr(idcbp1,ierr,ibc)
      call char2low(ibc)
      if (ierr.lt.0.or.ilen.lt.0) goto 800
      idummy = ichmv(lprocn,1,ib,9,12)
      goto 100
C
320   indexq = iabs(indexp)
      irecl = lproc2(4,indexq)
      id = fmpsetpos(idcbp2,ierr,irecl,-irecl)
      if (ierr.lt.0) goto 800
      ilen = fmpreadstr(idcbp2,ierr,ibc)
      call char2low(ibc)
      if (ierr.lt.0.or.len.lt.0) goto 800
      idummy = ichmv(lprocn,1,ib,9,12)
      goto 100
C
C
C     8. Abnormal error section.  There should be no errors, so
C     this is serious.
C
800   if (ierr.eq.-1) call logit6c(0,0,0,0,-128,'bo')
      if (ierr.lt.-1) call logit7ci(0,0,0,1,-129,'bo',ierr)
      if (ierr.eq. 0) call logit7ci(0,0,0,1,-130,'bo',ierr)
      istack(2) = 2
      lstack(2) = 2
C
900   return
      end
