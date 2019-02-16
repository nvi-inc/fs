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
      integer*2 ibuf2(512)
      integer*2 lch
      character cjchar
c
      if (ilxget.ne.0) goto 200
      if (itl1.lt.its1.or.
     &     (itl1.eq.its1.and.itl2.lt.its2).or.
     &     (itl1.eq.its1.and.itl2.eq.its2.and.itl3.lt.its3)
     &     ) goto 100
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
      ifirstday=-1
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
 400  continue
      do i=5,14
         if(index("0123456789",cjchar(ibuf,i)).eq.0) then
            if(i.eq.5) then
               logformat=3
            else if(i.eq.10) then
               logformat=1
               if(ichcm_ch(ibuf,10,";MARK I").eq.0) then
                  ich=10
                  ifirstday=ias2b(ibuf,1,3)
                  do k=1,8
                     call gtfld(ibuf,ich,ilen,ic1,ic2)
                  enddo
                  if(ic1.ne.0) then
                     iyear=ias2b(ibuf,ic1,ic2-ic1+1)
                     if(iyear.eq.-32768) iyear=1970
                  else
                     iyear=1970
                  endif
               else
                  iday=ias2b(ibuf,1,3)
                  if(ifirstday.eq.-1) then
                     ifirstday=iday
                     iyear=1970
                  else if(ifirstday.gt.iday) then
                     iyear=iyear+1
                     ifirstday=iday
                  endif
               endif
C not Y10K compliant
            else if(i.eq.14) then
               logformat=2
            else
               logformat=-1
            endif
            goto 110
         endif
      enddo
      logformat=-1
c
 110  continue
      if(logformat.eq.-1) then
        outbuf='LXOPN - error '
        call ib2as(-999,answer,1,4)
        call hol2char(answer,1,4,outbuf(15:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' unknown log file format '
        nchar = trimlen(outbuf) + 1
        call hol2char(logna,1,4,outbuf(nchar:))
        call po_put_c(outbuf)
        icode=-1
        goto 1200
      endif
c
      if(logformat.eq.1) then
         idyps=1
         ihrps=4
         imnps=6
         iscps=8
         ildch=10
         ifrst=11
      else if(logformat.eq.2) then
         idyps=3
         ihrps=6
         imnps=8
         iscps=10
         ihsps=12
         ildch=14
         ifrst=15
      else if(logformat.eq.3) then
C not Y10K compliant
         idyps=6
C not Y10K compliant
         ihrps=10
C not Y10K compliant
         imnps=13
C not Y10K compliant
         iscps=16
C not Y10K compliant
         ihsps=19
C not Y10K compliant
         ildch=21
C not Y10K compliant
         ifrst=22
      endif
c
      itl1 = ias2b(ibuf,idyps,3)
      if(logformat.eq.1) then
         itl1=itl1+(iyear-1970)*1024
      else if(logformat.eq.2) then
         iyr = ias2b(ibuf,1,2)
         if(iyr.lt.70) then
            iyr=iyr+2000
         else
            iyr=iyr+1900
         endif
         iyear=iyr
         ifirstday=itl1
         itl1= itl1+(iyr-1970)*1024
      else if(logformat.eq.3) then
         iyr=ias2b(ibuf,1,4)
         iyear=iyr
         ifirstday=itl1
         itl1=itl1+(iyr-1970)*1024
      endif
      itl2 = ias2b(ibuf,ihrps,2)*60 + ias2b(ibuf,imnps,2)
      itl3  = ias2b(ibuf,iscps,2)*100
      if(logformat.ne.1) then
         itl3=itl3+ias2b(ibuf,ihsps,2)
      endif
c      if (itl1.lt.its1.or.(itl1.eq.its1.and.itl2.lt.its2)) goto 200
      if (itl1.lt.its1.or.
     &     (itl1.eq.its1.and.itl2.lt.its2).or.
     &     (itl1.eq.its1.and.itl2.eq.its2.and.itl3.lt.its3)
     &     ) goto 200
      if (ikey.eq.9.or.ikey.eq.12) goto 1000
C
C  Find the number of characters in IBUF and store into NCHBUF
C
      nchbuf = iflch(ibuf(5),ilen-ildch)
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
        if (ichcm(ibuf2,ifrst,lcomnd(1,i),1,ncomnd(i)).eq.0)
     &       goto 600
500   continue
      goto 200
C
C  Determine whether a STRING Command was specified.  Then check for a
C  PLOT Command.  If a PLOT Command was issued, we skip the following
C  lines of code and continue with the LISTING code.
C
600   continue
      if (nstr.eq.0) goto 800
      do i=1,nstr
        if (nchbuf.ge.nstrng(i))  then
        if (iscns(ibuf2,ifrst,nchar,lstrng(1,i),1,nstrng(i)).ne.0)
     &          goto 800
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
      lch = jchar(ibuf2,ildch)
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
      if ((nlines.gt.0.and.nlout.lt.nlines).or.
     &     (nlines.eq.0.and.
     &     (itl1.lt.ite1.or.
     &     (itl1.eq.ite1.and.itl2.le.ite2).or.
     &     (itl1.eq.ite2.and.itl2.eq.ite2.and.itl3.le.ite3)
     & ))) goto 1200
      lstend=-1
      ilxget=0
C
1200  continue
      return
      end
