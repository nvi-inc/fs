      subroutine logen(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr,lwho,
     .                 lwhat,nargsin)
C 
C  LOGEN formats a buffer for the log file.
C  Character messages are displayed as is, errors are formatted
C  in a standard format. 
C  For normal Field System messages, only 6 parameters need be input.
C  For external messages, only 4 parameters are needed.
C  For error messages, all 8 (9 if LWHAT is present) parameters are
C  required although the message and procedure name are ignored for now. 
C 
C  INPUT: 
C 
      integer*2 lmessg(1)
C      - the buffer holding the message 
C     NCHAR - length of the message, in characters
C     LSOR - source of the message, 1 character (determined by BOSS)
      integer*2 lprocn(6) 
C      - the procedure file from whence this message came, 12 chars 
C     IERR - error number, if this is an error
C     LWHO - source of the error, 2 chars, e.g. Qx for QUIKR or BO for BOSS.
C     LWHAT - what caused the error (usually a device name), 2 chars. 
C             If LWHAT is binary, it is converted to a 4-char ASCII number. 
C             Indicate LWHAT is binary by setting LPROCN>0. 
C             This parameter should be 0 if not relevant. 
C 
C  OUTPUT:
C 
      integer*2 ibuf(1) 
C      - a buffer to hold the output entry
C     **NOTE** We assume that IBUF has at least enough room to
C              hold the message sent to us plus up to 16 more characters. 
C     NCH - number of characters in IBUF
C 
C  LOCAL: 
C 
      character cjchar
      dimension itime(5)
C      - to retrieve system time
C     NARGS - number of arguments passed to us
      integer*2 lname(3)
C      - the calling program's name 
      integer iyear
C 
C 
C     1. Get the number of parameters we were sent. 
C     Get the current time and put into our output buffer.
C 
      call fc_rte_time(itime,iyear) 
c
      nargs=abs(nargsin)
c
      nch = 1 + ib2as(mod(iyear,100),ibuf,1,o'41000'+2) 
      nch = nch + ib2as(itime(5),ibuf,nch,o'41000'+3) 
      nch = nch + ib2as(itime(4),ibuf,nch,o'41000'+2) 
      nch = nch + ib2as(itime(3),ibuf,nch,o'41000'+2) 
      nch = nch + ib2as(itime(2),ibuf,nch,o'41000'+2) 
      nch = nch + ib2as(itime(1),ibuf,nch,o'41000'+2) 
C 
C 
C     2. If this is an error message, format it appropriately.
C 
C     IF (IERR.EQ.0.OR.NARGS.LT.8) GOTO 300 
      if(nargs.lt.8) go to 300
      if(ierr.eq.0) go to 300
      nch = ichmv_ch(ibuf,nch,'?ERROR ') 
      nch = ichmv(ibuf,nch,lwho,1,2)
      nch = ichmv_ch(ibuf,nch,' ')
      nch = nch + ib2as(ierr,ibuf,nch,4)
C     IF (NARGS .LT. 9 .OR. LWHAT.EQ.0) GOTO 900
      if(nargs.lt.9) goto 900
      if(lwhat.eq.0) goto 900
      nch = ichmv_ch(ibuf,nch,'(')
      if (lprocn(1).le.0) nch = ichmv(ibuf,nch,lwhat,1,2)
      if (lprocn(1).gt.0) nch = nch+ib2as(lwhat,ibuf,nch,4)
      nch = ichmv_ch(ibuf,nch,')')
      goto 900
C 
C     3. This section is for Field System messages. 
C     Move procedure name and message into output buffer. 
C     If the first character of the message source is $ or &
C     then the procedure name should be logged. 
C 
300   if (nargs.lt.5) goto 400
cxx      nch = ichmv(ibuf,nch,lsor,2,1)
      nch = ichmv(ibuf,nch,lsor,1,1)
cxx      if ((cjchar(lsor,1).ne.'$'.and.cjchar(lsor,1).ne.'&').or.
cxx     .     nargs.eq.5) goto 350 
      if ((cjchar(lsor,1).ne.'$'.and.cjchar(lsor,1).ne.'&')) goto 350 
C                   Find last non-blank character in proc name
      i = iflch(lprocn,12)
      nch = ichmv(ibuf,nch,lprocn,1,i)
C                   Move proc name into output buffer 
      nch = ichmv_ch(ibuf,nch,'/')
C                   Put a / after proc name 
350   nch = ichmv(ibuf,nch,lmessg,1,nchar)
C                   Finally move the log entry in 
cxx      write(6,9200) (ibuf(i),i=1,15)
cxx9200  format(1x,"LOGEN: ibuf=",15a2)
      if(nargsin.eq.-6) then
         nch=nch+ib2as(iyear,ibuf,nch,4)
         nch=mcoma(ibuf,nch)
         nch=nch+ib2as(itime(5),ibuf,nch,3)
      endif
      goto 900
C 
C 
C     4. This section is for non-Field System entries.
C     Get the calling program's name and put it into the entry. 
C     Identify this type of entry with the special character #. 
C 
400   continue
      call pname(lname) 
C                   Get our caller's name 
      nch = ichmv_ch(ibuf,nch,'#')
C                   Put the message type special character into the buffer
      i = iflch(lname,5)
C                   Search the name for trailing blanks 
      nch = ichmv(ibuf,nch,lname,1,i) 
C                   Move the program name into the bufer
      nch = ichmv_ch(ibuf,nch,'#')
C                   Put a # after the program name
      nch = ichmv(ibuf,nch,lmessg,1,nchar)
C                   Finally, move in the message part itself
900   return
      end 
