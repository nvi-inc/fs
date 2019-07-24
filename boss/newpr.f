      subroutine newpr(idcbp1,idcbp2,istack,index,
     .lparm,nparm,lstack,lproc1,lproc2,itmlog,ibuf,iblen,ierr)
C
C     NEWPR - initializes a new procedure by manipulating the stacks
C
C     DATE   WHO CHANGES
C     810907 NRV Modified for new procedure management
C     840217 MWH Modified stack structure
C
C  INPUT:
C
C     IDCBP1,IDCBP2 - DCBs for the two procedure files
C     ISTACK - stack of procedure information
C              (1) = total number of words available
C              (2) = last word used, if 2 then empty
C              Items are pushed onto the stack in the order:
C              - index into LPROC1,2 array (>0=1,<0=2)
C              - next line number when pushed down
C     INDEX - index into LPROC1,LPROC2 arrays
C             >0 is LPROC1, <0 is LPROC2
C     LPARM - parameter string specified with this proc
C     NPARM - number of characters in LPARM
C     LSTACK - stack of parameters
C              (1) = total number of words
C              (2) = last word used, =2 means empty
C              The parameter string is pushed first, then
C              the number of characters in it.
C     LPROC1,2 - procedure directories
C     ITMLOG - time this log file was started
C     IBUF - buffer for reading
C     IBLEN - length of IBUF
      dimension istack(1),lstack(1),lparm(1)
      dimension idcbp1(1),idcbp2(1),itmlog(1)
      integer*2 ibuf(1)
      integer*2 lproc1(10,1),lproc2(10,1)
C
C  OUTPUT:
C
C     IERR - error return.  -1 for stack error, <0 for FMP error.
C
C
C  LOCAL:
C
C     LPROCN - procedure name, for logging
C     NREC - next record number in current file, from FmpPosition
C     ITIME - holds the current system time, for comparing with ITMLOG
C     IREC,IOFF - position information for current procedure
      integer*4 irec,ioff
      integer fmpposition,fmpreadstr,fmpsetpos,fmpwritestr
      integer fmppost
      dimension itime(6),lprocn(6)
      character*80 ibc
      integer*2 ib(40)
      equivalence (ib,ibc)
C
C
C  INITIALIZED:
C
C     1. Determine position information for the new procedure
C
      if (index.gt.0) goto 100
        irec = lproc2(8,iabs(index))
        go to 200
100   continue
      irec = lproc1(8,index)
C
C     2. Position to the new location in the procedure file.
C     If there are errors, or DEFINE is not on this line, then quit.
C
200   continue
      if (index.gt.0) id = fmpsetpos(idcbp1,ierr,irec,-irec)
      if (index.lt.0) id = fmpsetpos(idcbp2,ierr,irec,-irec)
      if (ierr.lt.0) goto 800
      if (index.gt.0) ilen = fmpreadstr(idcbp1,ierr,ibc)
      if (index.lt.0) ilen = fmpreadstr(idcbp2,ierr,ibc)
      call char2low(ibc)
      if (ierr.lt.0.or.ilen.le.0) goto 800
      if (ibc(1:6).ne.'define') goto 800
C
C     3. Get the time field from the first line and check it against
C     the time the log was opened.
C     If the time the procedure was last logged is later than
C     the time the log file was started, then we are finished here.
C     Otherwise, drop through to the logging of this procedure.
C
300   continue
      if (ias2b(ib,23,2).gt.itmlog(6)-1900) goto 600
      if (ias2b(ib,23,2).lt.itmlog(6)-1900) goto 400
C                   First check the year
      if (ias2b(ib,25,3).gt.itmlog(5)) goto 600
      if (ias2b(ib,25,3).lt.itmlog(5)) goto 400
C                   Then check the day number
      timlog = itmlog(4)*3600.0+itmlog(3)*60.0+itmlog(2)
      timprc = ias2b(ib,28,2)*3600.0+ias2b(ib,30,2)*60.0+
     .         ias2b(ib,32,2)
      if (timprc.gt.timlog) goto 600
C                   Finally check the time of day, if the dates are equal
C
C
C     4. This procedure needs logging.  Read/log each record.
C     First pull off the procedure name.
C
400   idummy = ichmv(lprocn,1,ib,9,12)
410   if (index.gt.0) ilen = fmpreadstr(idcbp1,ierr,ibc)
      if (index.lt.0) ilen = fmpreadstr(idcbp2,ierr,ibc)
      call char2low(ibc)
      if (ilen.eq.0.or.ibc(1:6).eq.'define'.or.ibc(1:6).eq.'enddef')
     .   goto 500
      if (ierr.lt.0.or.ilen.le.0) goto 800
      ilen = iflch(ib,80)
      call logit4(ib,ilen,2h&&,lprocn)
      goto 410
C
C
C     5. Finally, update the first line of the procedure with
C     the current time, to indicate the last time we logged it.
C
500   if (index.gt.0) id = fmpsetpos(idcbp1,ierr,irec,-irec)
      if (index.lt.0) id = fmpsetpos(idcbp2,ierr,irec,-irec)
      if (ierr.lt.0) goto 800
      if (index.gt.0) ilen = fmpreadstr(idcbp1,ierr,ibc)
      if (index.lt.0) ilen = fmpreadstr(idcbp2,ierr,ibc)
      call char2low(ibc)
      call fc_rte_time(itime,itime(6))
      idummy = ib2as(itime(6)-1900,ib,23,2)
      idummy = ib2as(itime(5),ib,25,o'40000'+o'400'*3+3)
      idummy = ib2as(itime(4),ib,28,o'40000'+o'400'*3+2)
      idummy = ib2as(itime(3),ib,30,o'40000'+o'400'*3+2)
      idummy = ib2as(itime(2),ib,32,o'40000'+o'400'*3+2)
      ibc(34:34) = 'x'
C                   Pad with character to fill in last byte
      if (index.gt.0) id = fmpsetpos(idcbp1,ierr,irec,-irec)
      if (index.lt.0) id = fmpsetpos(idcbp2,ierr,irec,-irec)
      if (index.gt.0) id = fmpwritestr(idcbp1,ierr,ibc(:ilen))
      if (index.lt.0) id = fmpwritestr(idcbp2,ierr,ibc(:ilen))
      if (index.gt.0) id = fmppost(idcbp1,ierr)
      if (index.lt.0) id = fmppost(idcbp2,ierr)
C
C
C     6. Push location information on the stack first.  Then push the
C     new name onto the stack for retrieval by READP.
C     Push parameter string and number of character, if any onto stack.
C
600   continue
      if(index.gt.0)id = fmpposition(idcbp1,ierr,irec,ioff)
      if(index.lt.0)id = fmpposition(idcbp2,ierr,irec,ioff)
      if(ierr.lt.0)goto 800
      irecs = irec
      call prput(istack,irecs,1,ierr)
      if(ierr.ne.0)goto 800
      call prput(istack,index,1,ierr)
      if (nparm.ne.0) call prput(lstack,lparm,(nparm+1)/2,ierr)
      if (ierr.ne.0) goto 800
      call prput(lstack,nparm,1,ierr)
      if (ierr.ne.0) goto 800
      goto 900
C
C
C     8. This is the abnormal error section.  There should be no
C     errors in this routine because all of the file has been checked
C     before.  So this is serious.
C
800   if (ierr.eq.-1) call logit7(0,0,0,1,-128,2hbo,ierr)
      if (ierr.ne.-1) call logit7(0,0,0,1,-129,2hbo,ierr)
      istack(2) = 2
      lstack(2) = 2
C
C
900   continue
      return
      end
