      program rwand
C
      include '../include/fscom.i'
C
C  Programmed by Lloyd Rawley, March 1988.   Last update <890623.2034>
C
C  Subroutines called:  logit, cksum, bsort, character routines
      logical cksum
C
      parameter (lenbuf=3306)      !  maximum length of wand buffer
      parameter (messmax=63)       !  maximum message length for logit
      parameter (idevmax=64)       !  maximum message length for logit
      parameter (idevto=10)        !  units of centiseconds
      parameter (icret=13)         ! terminating character
      parameter (iendc=-1)         ! terminating character
      parameter (ibaud=1200)       ! self explanatory
      parameter (iparity=0)        ! self explanatory
      parameter (ibits=8)          ! self explanatory
      parameter (istop=2)          ! self explanatory

C
C  Common block FSCOM contains LUs for bar code reader and screen output.
C  
      integer*2 mess(32),idtape(8)  ! character buffers
      integer*2 buf1(lenbuf), bufr(lenbuf)
      integer*2 buftmp
      integer portopen, portread, portwrite, portflush
      integer itimeout
      integer istart(64), length(64)       ! word delimiters within bufr
      integer indev
      integer bigC
      logical rn_test
C
      integer ichcm, ichmv, iflch
C
      data bigC /z'0d43'/
      data idtape/2HNA,2HSA,2H/M,2HK ,2H3/,2HTA,2HPE,2H/ /
C          nasa/mk 3/tape/
C
      call setup_fscom
      call read_fscom
      call putpname('rwand')

      if (.not.rn_test('fs   ')) then
        write(6,9100) 'Field System NOT running!'
9100    format(/,1x,a,/)
        stop
      endif

      ibufln = lenbuf*2
C
C  Set up port for 8 data bits, 2 stop bits, no parity, 1200 baud, etc.
C  There are no special characters in the input stream to signify the end
C  of transmission, so we simply read whatever is in the input buffer
C  when the device times out.  (If data were read character by character,
C  some characters would be lost due to the lack of protocol.)
C
      indev = iflch(idevwand,idevmax)
      ierr=portopen(luwand,idevwand,indev,ibaud,iparity,ibits,istop)
C
      if (ierr.lt.0) then
        call logit2_ch('RWAND: cannot open port for reading')
        goto 9999
      endif
C
      ierr = portflush(luwand)
      if (ierr.ne.0) then
        call logit2_ch('RWAND: error flushing port')
        goto 9999
      endif
C
      nchar = 0
      ierr=0
C
      call ifill_ch(buf1,1,lenbuf*2,' ')
      call ifill_ch(bufr,1,lenbuf*2,' ')

      write(6,9300)
9300  format(1x,"RWAND: insert wand in recharger and press button",/)

      itimeout=3000   !! 30 second wait for operator to respond
      ierr = portread(luwand,buftmp,ibufln,1,iendc,itimeout)

      if (ierr.eq.-2) then
        call logit2_ch('RWAND: timeout occurred')
        goto 9999
      endif

      if (ierr.ne.0) then
        call logit2_ch('RWAND: error reading TimeWand')
        goto 9999
      endif
C
C Check to see if first character read is a carraige return. If yes,
C no information is in the timewand.
C
      if (buftmp .eq. 13) then
        call logit2_ch('RWAND: no information from TimeWand')
        goto 9999
      endif

      itemp = ichmv(buf1(1),1,buftmp,1,1)
C
C Loop until two consecutive carriage returns are read. This indicates
C the end of all bar code informations contained in reader.
C
      itotlen=ibufln
      idone=0
      itimeout=-1  !! disable timeout
      do while (idone.lt.2) 
        ierr = portread(luwand,buftmp,ibufln,1,iendc,itimeout)
        if (ierr.ne.0) then
          call logit2_ch('RWAND: error reading TimeWand')
          goto 9999
        endif
        itotlen= itotlen+ibufln
        itemp = ichmv(buf1,itotlen,buftmp,1,ibufln)
        if (buftmp .eq. 13) then
          idone=idone+1
        else
          idone=0
        endif
      enddo
C
C  Now read the checksum.
C
      ierr = portread(luwand,buftmp,ibufln,1,iendc,itimeout)
      if (ierr.ne.0) then
        call logit2_ch('RWAND: error reading TimeWand')
        goto 9999
      endif
      itotlen= itotlen+ibufln
      itemp = ichmv(buf1,itotlen,buftmp,1,ibufln)
      do while (buftmp.ne.13)
        ierr = portread(luwand,buftmp,ibufln,1,iendc,itimeout)
        if (ierr.ne.0) then
          call logit2_ch('RWAND: error reading TimeWand')
          goto 9999
        endif
        itotlen= itotlen+ibufln
        itemp = ichmv(buf1,itotlen,buftmp,1,ibufln)
      enddo

      nchar = itotlen
      itemp = ichmv(bufr,1,buf1,1,nchar)

      if (.not.cksum(bufr,nchar)) then
        call logit2_ch('RWAND: checksum failed')
        goto 9999
      endif

      ich = 1
      nchar = nchar-4              ! because final characters are checksum
      ncode = 0
      do while (ich.lt.nchar)
C Ignore the special character (ASCII 1) which begins keypad reads.
        if (ichcm(bufr,ich,1,2,1).eq.0) ich=ich+1
        call pchar(idum,2,13)
        nch = iscnc(bufr,ich,nchar,13)       ! find carriage return
        ncode = ncode+1  
        istart(ncode) = ich
        length(ncode) = nch-ich
        ich = nch+1
      enddo
C
C Sort the bar codes by length and ASCII sequence, removing any readings
C of tape labels other than the last label in the chronological list.
C
      call bsort(istart,length,ncode,bufr)
C
C Send lists of bar codes to LOGIT, ignoring duplicates.
C
      nchar = 0
      do i=1,ncode
        if (length(i).ne.nchar) then
          if (nchar.ne.0) call logit2(mess,ncmess-1)   ! log previous message
          nchar = length(i)
          nstart = 5*(nchar/2)-14          ! 6-> 1, 8-> 6, 10-> 11
          if (nstart.le.0) nstart = 1
          ncmess = ichmv(mess,1,idtape,nstart,5)         ! start new message
          ncmess = ichmv(mess,6,bufr,istart(i),nchar)
        else if (ichcm(bufr,istart(i),bufr,istart(i-1),nchar).ne.0) then
          if (ncmess+nchar.le.messmax) then
C Add bar code (preceded by a comma) to the message string
            ncmess = ichmv(mess,ncmess,o'54',1,1)
            ncmess = ichmv(mess,ncmess,bufr,istart(i),nchar)
          else
            call logit2(mess,ncmess-1)        ! log previous message
            ncmess = ichmv(mess,6,bufr,istart(i),nchar)  ! start new line
          endif
        endif
      enddo
      if (nchar.ne.0) call logit2(mess,ncmess-1)  ! log last line of message
C
      ierr = portwrite(luwand,bigC,2)      !  clear timewand memory
9999  continue
      write(6,7666) 'hit return to continue'
7666  format(1x,a)
      read(5,7654) cchr
7654  format(a)
C
      end
