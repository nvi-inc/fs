      subroutine lxget
C
C LXGET - Gets the next selected entry based on start & stop times,
C         number of lines specified, COMMAND command, STRING, & TYPE
C         commands.
C
C MODIFICATIONS:
C
C    DATE     WHO  DESCRIPTION
C    820325   KNM  SUBROUTINE CREATED
C
C    820519   KNM  GETTING THE SELECTED ENTRY BASED ON THE FIRST
C                  COMMAND SPECIFIED IN THE COMMAND COMMAND WAS
C                  ADDED FOR THE PLOT COMMAND. THE OLD PLOT COMMAND
C                  IS NOW CALLED TPLOT AND THE NEW COMMAND IS CALLED
C                  PLOT.
C
C OUTPUT VARIABLES:
C
C     ICODE - Error flag
C
C COMMON BLOCKS USED:
C
      include 'lxcom.i'
C
C
C SUBROUTINE INTERFACES:
C
C     CALLED ROUTINES:
C
C     LXSUM - SUMMARY command.
C     LXPLT - PLOT command.
C     LXIST - LIST command.
C
C     CALLING SUBROUTINES:
C
C     File manager package routines
C     LNFCH Utilities
C
C LOCAL VARIABLES:
C
C     NCHBUF - Number of characters in IBUF past time field.
C     NREC - number of records in IBUF.
C
C INITIALIZED VARIABLES:
C
C
C  *****************************************************************
C
C  1. Check to determine whether the log day is before the specified
C     start day. If the log and start day are the same, check to see
C     if the log minutes are less than the starting minutes. If the
C     log minutes are greater than the starting minutes, then rewind
C     the log file.
C
C  *****************************************************************
C
C
      integer fmpread
      character*79 outbuf
      integer answer, trimlen
      integer*2 ibuf2(50)
      integer*2 lch

      if (ilxget.ne.0) goto 200
      if (itl1.lt.its1.or.(itl1.eq.its1.and.itl2.lt.its2)) goto 100
C
C  Call rewind to begin at the first log entry.
C
      ierr = 0
      call fmprewind(idcb,ierr)
      if (ierr.ne.0) then
        outbuf='LXGET01 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' rewinding log file.'
        call po_put_c(outbuf)
        ilen=-1
        ilxget=0
        goto 1200
      endif
      nrec = 0
100   continue
      nlout = 0
      ilxget=1
C
C
C  *************************************************************
C
C  2. Each return to call READF will read the next log entry
C
C  *************************************************************
C
C
200   continue
      ilen = fmpread(idcb,ierr,ibuf,iblen*2)
C
      nchar=ilen
C
      if (ierr.lt.0) then
        outbuf='LXGET10 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' reading log file.'
        call po_put_c(outbuf)
      end if
      if (ilen.gt.0) goto 300
      if (ilen.eq.0) goto 200   ! empty record
        ilen=-1
        ilxget=0
        goto 1200
300   nrec = nrec + 1
C
C  To stop the listing, hit the break key.
C    above currently unavailable
cxx      if (ifbrk(idum).lt.0) then
cxx        icode=-1
cxx        goto 255
cxx      end if
      if (ilen.ge.0) goto 400
255   if (icode.eq.-1.or.ilen.lt.0) ilxget=0
      goto 1200
C
C
C  ************************************************************
C
C  3. Get day and time from log file and compare to start time.
C     If a command was specified, check for its name.
C
C  ************************************************************
C
C
C  Convert ASCII string to Binary integer to obtain day for ITL1
C  and minutes for ITL2
C
400   itl1 = ias2b(ibuf,3,3)
      itl2 = ias2b(ibuf,6,2)*60 + ias2b(ibuf,8,2)
      it3  = ias2b(ibuf,10,2)
      if (itl1.lt.its1.or.(itl1.eq.its1.and.itl2.lt.its2)) goto 200
      if (ikey.eq.9.or.ikey.eq.12) goto 1000
C
C  Find the number of characters in IBUF and store into NCHBUF
C
      nchbuf = iflch(ibuf(7),ilen-14)
C
C
C  ************************************************************
C
C  4. Determine selected entry for listing by checking for a
C     COMMAND command, STRING, and TYPE command.
C
C  ************************************************************
C
C
cxx      write(6,9000) ncmd, ntype, nstr
9000  format(1x,"LXGET: ncmd=",i6," ntype=",i6," nstr=",i6)
      if (ncmd.eq.0) goto 600
C
C  If a COMMAND command was specified, check to see if a PLOT command
C  was issued. If a PLOT command was specified, the first command in
C  the COMMAND command is only used.
C
      call mvupper(ibuf2,1,ibuf,1,nchar)
      do 500 i=1,ncmd
        if (i.gt.1.and.(ikey.eq.6.or.ikey.eq.13)) goto 500
        if (nchbuf.lt.ncomnd(i)) goto 500
        if (ichcm(ibuf2,15,lcomnd(1,i),1,ncomnd(i)).eq.0) goto 600
500   continue
      goto 200
C
C  Determine whether a STRING Command was specified.  Then check for a
C  PLOT Command.  If a PLOT Command was issued, we skip the following
C  lines of code and continue with the LISTING code.
C
600   if (nstr.eq.0) goto 800
      do i=1,nstr
        if (nchbuf.ge.nstrng(i))  then
        if (iscns(ibuf2,15,nchar,lstrng(1,i),1,nstrng(i)).ne.0) goto 800
        endif
      end do
      goto 200
C
C  Determine whether a TYPE command was specified.
C
800   if (ntype.eq.0.or.ntype.eq.o'40') goto 1000
C
C  JCHAR returns LCH as zero/character. To left justify multiply
C  o'400' (256 decimal) and add a blank (o'40').
C
cxx      lch = jchar(ibuf2,10)*o'400'+' '
      lch = jchar(ibuf2,14)
      do i=1,ntype
        if (lch.eq.ltype(i)) goto 1000
      end do
      goto 200
C
C
C  ************************************************************
C
C  5. Determine whether the number of lines outputted exceeds
C     the number of lines specified. Then proceed to make sure
C     that the log day and minutes do not exceed the stop day
C     and minutes. If the stop time or # lines specified passes
C     these conditions, write out IBUF.
C
C  ************************************************************
C
C
1000  continue
      if ((nlines.gt.0.and.nlout.lt.nlines).or.(nlines.eq.0.and.
     .(itl1.lt.ite1.or.(itl1.eq.ite1.and.(itl2.le.ite2))))) goto 1200
      lstend=-1
      ilxget=0
C
1200  continue
      return
      end
