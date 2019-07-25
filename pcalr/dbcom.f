      subroutine dbcom(luop,ludb,ibugpc,ibuf,nchar,idata,ilog,ierr, 
     .iblk,istat,id,kdbtst,idcb,ibdb)
C 
C     This routine handles the communications with the
C     Mark III data buffer or the terminal or data file 
C     as appropriate.  If there is an error in communications
C     with the data buffer (either wrong length record or incorrect
C     checksum) a total of NLOOPT attempts at comms are made
C     before giving up.
C
C  INPUT:
C
C     LUOP - LU for debug output
C     LUDB - LU of data buffer
      integer*2 ibuf(1)
C      - buffer holding command to be sent to data buffer
C     NCHAR - number of characters in the command in IBUF
      dimension idata(1)
C      - data returned from data buffer
      dimension idcb(1)
C      - DCB for data file
      logical kdbtst
C     KDBTST - true if we have a real data buffer
C
      integer portflush,portwrite,portread
C
C  OUTPUT:
C
C     IERR - error return, 0=OK
C     IBLK - block number pointer
C     ISTAT - data buffer status
C     ID - data buffer ID word
C
C
C     LOCAL:
      character cjchar
C
C     ILENB - expected length of response from data buffer
C     NCH - character counter
      dimension ireg(2)
C     ILOG - actual length of response from data buffer
C     ICHEK, JCHEK - checksum characters
      equivalence (ireg(1),reg)
c     data nloopt/5/
C     NLOOPT - max number of times to try and get correct response
C              from data buffer.
C
C     1. Figure out how many characters we expect to get back.
C     Then write the command to the data buffer.
C     Read back its response.
C
      nloop = 0
      il = 260
      ilenb = 4
      if (cjchar(ibuf,1).eq.'?') ilenb = 516
C                   Suppress CRLF on transmission
      nch = nchar
99    continue
      if (kdbtst) then
        ierr=portflush(ludb)
        ierr=portwrite(ludb,ibuf,nch)
      endif
      ierr = 0
      call ifill_ch(idata,1,520,' ')
      nloop = nloop+1
C                   Send the command to data buffer or terminal
C
C*************FOR THE REAL DATA BUFFER USE o'100'+LU******************
C*************FOR TERMINAL TESTING     USE  o'400'+LU******************
      if (kdbtst) then
        itn=ilenb*1.5*1100./ibdb+5.0001
        if(ilenb.eq.4) itn=itn+10
        ierr=portread(ludb,idata,ireg(2),ilenb,-1,itn)
        goto 100
      endif
C
C                   Issue binary read, buffer mode
      ir = fmpread(idcb,ierr,idata,il*2)
      ilog = 0
      if (ir.eq.-1) ilog = -1
      ireg(2) = iflch(idata,520)
      l = ih22a(jchar(idata,516))
      if (ibugpc.gt.2) write(luop,9509) (idata(248+k),k=1,10)
9509  format(1x,"last 10 words idata = "10(o7,2x)) 
c     if (ireg(2).eq.515.and.l.eq.2h20) ireg(2)=516 
      if (ireg(2).eq.515.and.jchar(idata,516).eq.z'20') ireg(2)=516 
      if (ierr.eq.0.and.ilog.ne.-1) goto 100
      if (ierr.ne.0) write(luop,9120) ierr
      if (ilog.eq.-1) write(luop,9220)
9220  format(1x," eof in data file, quitting") 
9120  format(1x," error "i5" reading from data file")
      goto 990
C 
100   ilog = ireg(2)
C 
      if (ibugpc.lt.2) goto 300 
      write(luop,9110)
9110  format(1x,"raw received data"/)
      do 200 i=1,ilog 
      l = jchar(idata,i)
C***FOR DATA BUFFER, CONVERT FROM HEX BITS TO ASCII FOR PRINTING
      l = ih22a(l)
      write(luop,9100) l
 9100 format(1x,a2" ",$)
200   continue
C 
C 
C     2. Check all possible errors. 
C 
300   ierr = 0
      if (ilog.ne.ilenb) ierr=-1
      ichek = jchar(idata,ilog) 
      jchek = 0 
      do i=1,ilog-1 
        jchek = and(jchek+jchar(idata,i),o'377') 
      enddo
      if (ichek.ne.jchek) ierr=-2 
C 
      if (ierr.ne.0) go to 990
C 
      istat = jchar(idata,1)
      iblk = jchar(idata,2) 
      id = jchar(idata,ilog-1)
C 
990   continue
C 
      return
      end
