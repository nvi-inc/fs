*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
        SUBROUTINE LABEL(PCODE,kskd,cr1,cr2,cr3,cr4,inew)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C This routine types labels for Mark III tapes

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

C INPUT:
C        PCODE - 1 or 2 open file
C                1 or 3 close file
      integer pcode
      logical kskd
      character*(*) cr1,cr2,cr3,cr4
      integer inew ! 1 to start a new ps barcode file
C OUTPUT: none


!fucntions
      INTEGER TRIMLEN
      integer copen
      integer cclose
      real speed ! function

C LOCAL:
      character*128 cout
      integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN),
     .          LMON(2),LDAY(2),LPRE(3),LMID(3),LPST(3),ldir(max_stn)
      integer IFT(MAX_STN),IPAS(MAX_STN),IDUR(MAX_STN),ioff(max_stn)
      integer iob,ilabrowin,ilabcolin
      LOGICAL   KEX,ks2
      character*8 ctape_num


C IYR, MON, IDA, IHR, iMIN, IDUR, ICAL, IDLE,
C LFREQ, ISP, LMODE,
C These are holders for the information contained
C in a single observation.  All are returned from UNPAK.
C IDAYR, MJD
      double precision UT, GST
C These are computed in UNPAK and returned.
C NSTNSK - number of stations in current observation
C NLAB - number of labels across a page
      integer mjd,ida,iyr2,iyear,iyr,idayr,ihr,imin,isc,
     .idayr2,ihr2,imin2,isc2,mon
      integer ipsy1,ipsy2,ipsd1,ipsh1,ipsm1,ipsd2,ipsh2,ipsm2
      integer istnsk,isor,icod,iftold,nout,nlabpr,ilen,ical,
     .nstnsk,idir,idirp,ipasp,ierr,ntape
      integer*2 lfreq
      integer IY1(5),ID1(5),IH1(5),IM1(5),
     .          iy2(5),ID2(5),IH2(5),IM2(5) ! holders for row of labels
      LOGICAL KNEWT
      LOGICAL KNEW
      integer ic
      CHARACTER*50 ctmp
      character*8 cstat
      character*1 cid1
      character*2 cid2
      character*20 response
      integer*2 hhr
      integer i
      character upper

      character*(max_sorlen) csname
      character*2 cstn(max_stn)
      character*2 cfreq
      equivalence (csname,lsname),(lstn,cstn),(cfreq,lfreq)

C INITIALIZED:
      DATA IPASP/-1/, IFTOLD/0/
      DATA  HHR/2HR /

C SUBROUTINES CALLED:
C  UNPSK - unpacks schedule file entry
C  TMADD - calculates stop time
c  DLABL, BLABL - print labels on Epson or Laser
C
C HISTORY:
C  821130 WEH Changed the format statements in "type a row" to
C              prevent an extra label from being typed on.
C              Changed the IF$ test for "process this observation" to
C              include EOF and end of section conditions. This
C              catches the last row of labels for those stations
C              not involved in the last scheduled observation.
C  880411 NRV DE-COMPC'D
C  881013 NRV ADDED ICRTY6 TO CALL TO DLABL
C  881021 NRV Added option for bar code labels on laser printer
C  890116 NRV Added BReak
C  890505 NRV CHANGED IDUR TO AN ARRAY BY STATION
C  900103 PMR changed to use temp file for printing
C  900413 NRV Changed call to printer routine to use commands
C              from control file.  Added BREAK.
C  910703 NRV Add PRTMP call at end
C  930412 nrv implicit none
C  930602 nrv Remove check for EOF at top of reading loop so that if
C             the $SKED section is last in the file the last line of
C             labels will be spit out.
C  940627 nrv Add batch mode
C  950829 nrv Remove ' ' in front of lines written to CLASER
C 960531 nrv Remove READS and get obs from common.
C 960810 nrv Change itearl to array
C 960820 nrv Don't try to use SPEED in a calculation for S2.
C 970121 nrv Change 4 to max_sorlen
C 970121 nrv Add IIN to call. Add call to make_pslabel and other
C            C routines.
C 970228 nrv Remove IIN and use CLABTYP to determine what type of output.
C 970228 nrv Use labname for output file.
C 970312 nrv Add call to READ_SNAP1 to read first line freeform.
C 970827 nrv Add startlab to make_pslabel call. Add prompts for
C            starting position of label.
C 971014 nrv Add better S2 logic.
C 971028 nrv Force new tape when starting a schedule (this was needed for
C            S2 in case it starts in middle of tape).
C 980916 nrv Add IY2 to hold the year of the stop times.
C 000107 nrv Calculation of IFTOLD does not use ITUSE but includes
C            ITEARL always. KNEWT was modified to allow more buffer,
C            but this will not always work. Calculation of IFTOLD is not
C            correct.
C 000705 nrv Use standard KNEWT for S2 also.

! 2004Sep??  JMGipson Added support for dymo printer.
! 2004Oct19  JMGipson.  Fixed problem if you were printing out several experiments in a row.
!
! 2005Mar07  JMGipson.  Fixed problem with last label. Previously ending time was
!            that of penultimate scan. Now it is time of last scan.
! 2005Jul25  JMGipson. Modifed dymo printer to always be row1, col1.
!            Also modified psbar (which prints the labels) to put showpage at the end of each label.
!
! 2005Aug04 JMGipson.  Modifed make_pslabel to accept 8 character
!            tape_label ctape_num. This is so we can use this for VSN#s
! 2006Oct17 JMGipson. Added argument to cclose(fp, clabtyp). Clabyp indicates kind of printer.
! 2007May25 JMGipson made lstcod, lstnna, lexper ASCII (cstcod,cstnna,cexper)

C 1. First get set up with schedule or SNAP file.


      if (kskd) then
        IC = TRIMLEN(LSKDFI)
        WRITE(LUSCN,9100) cSTNNA(ISTN),LSKDFI(1:ic)
9100    FORMAT(' TAPE LABELS FOR ',A8,' FROM SCHEDULE FILE ',A)
      else ! Check existence of SNAP file.
        IC = TRIMLEN(CINNAME)
        INQUIRE(FILE=CINNAME,EXIST=KEX)
        IF (.NOT.KEX) THEN
          WRITE(LUSCN,9398) CINNAME(1:IC)
9398      FORMAT(' LSTSHFT01 - SNAP FILE ',A,' DOES NOT EXIST')
          RETURN
        ENDIF
        OPEN(LU_INFILE,FILE=CINNAME,STATUS='OLD',IOSTAT=IERR)
        IF(IERR.EQ.0) THEN
          REWIND(LU_INFILE)
        ELSE
          WRITE(LUSCN,9400) IERR,CINNAME(1:IC)
9400      FORMAT(' LSTSHFT02 - ERROR ',I3,' OPENING SNAP FILE ',A)
          RETURN
        ENDIF
        read(lu_infile,'(a)',err=990,end=990,iostat=IERR) ctmp
C       read(ctmp,9001) cexper,iyear,cstn,cid
C9001    format(2x,a8,2x,i4,1x,a8,2x,a1)
        call read_snap1(ctmp,cexper,iyear,cstat,cid1,cid2,ierr)
        if (ierr.lt.0) then ! set defaults instead
          if (ierr.ge.-1) cexper='XXX'
          if (ierr.ge.-2) iyear=0
          if (ierr.ge.-3) cstat='        '
          if (ierr.ge.-4) cid1=' '
          if (ierr.ge.-5) cid2='  '
        endif
        ierr=0
        cstat(1:8)=cstnna(1)(1:8)
        cstcod(istn)=cid1
        ic=trimlen(cinname)
        write(luscn,9002) cstat,cinname(1:ic)
9002    format(' Tape labels for ',a8,' from SNAP file ',a)
        call labsnp(nlabpr,iyear,inew)
        goto 900
      endif !read schedule/SNAP file
C
C
      NOUT = 0
      NLABPR = 0
      ntape=0
      IPASP=-1
      ks2=cstrack(istn).ne.'unknown'.and.cstrec(istn,1).eq. 'S2'

C  If label printer is postscript then don't open the file, that
C  will be done later with a C call.
C  If pcode is 1 or 2, we want to open up the output, otherwise,
C  we assume it is already open.
      if (.not.klabel_ps) then ! only for laser or epson
        IF ((PCODE.EQ.1).OR.(PCODE.EQ.2)) THEN !first station
          call setprint(ierr,0)
          IF (IERR.NE.0) THEN
            WRITE(LUSCN,9061) IERR
9061        FORMAT(' LABEL01 - ERROR ',I5,' ACCESSING PRINTER ')
            RETURN
          ENDIF

          IF (clabtyp.eq.'LASER+BARCODE_CARTRIDGE'.or.
     .        cprttyp.eq.'FILE') THEN
C                            !set up laser printer
            NLAB=3           !3 labels across on laser paper
            if (kbatch) then
              read(cr1,*,err=991) ilabrow
991           if (ilabrow.lt.1.or.ilabrow.gt.8) then
                write(luscn,9991) ilabrow
9991            format(' Invalid label position ',2i4)
                return
              endif
            else
91            WRITE(LUSCN,'(a)')
     >        " Make sure the bar code font cartridge is installed."
              write(luscn,'(a,$)')
     >        " Enter position of first label (1 through 8, 0 to quit)?"
              READ(LUUSR,*,ERR=91) ILABROW
              IF(ILABROW.EQ.0) GOTO 990
              IF(ILABROW.LT.1.OR.ILABROW.GT.8) GOTO 91
            endif
C
C <esc>&l2H   manual paper feed
C <esc>&l0O   portrait
C <esc>&l48D  set to 48 lines/inch
C <esc>&l528P 528 lines/page
C <esc>&l2E   set top margin at line 2 (1/24" from top)
C <esc>&l526F 526 lines of text
C <esc>&a0R   start with row 0
C <esc>&a0L   set left margin at left edge of paper
C <esc>&l0L   perf skip disable
C <esc>&l6D   6 lines/inch
C
             WRITE(luprt,'(a)')  CHAR(27)//'&l0O'//CHAR(27)//
     >        '&l48d528p2e526F'//CHAR(27)//'&a0R'//CHAR(27)//'&a0L'//
     >         CHAR(27)//'&l0L'//CHAR(27)//'&l6D'//char(13)

          else if (clabtyp.eq.'EPSON24') then ! Epson 24-pin setup
            write(luprt,'(a,$)')
     >             char(27)//char(64)//char(27)//char(65)//char(12)
!           <esc>@ power up reset  plus <esc> A 12 for 24-pin
            nlab = 1  !1 across
          else ! Epson setup
            write(luprt,'(a,$)') char(27)//char(65) !<esc>@ power up reset
            nlab = 1  !1 across
          ENDIF !set up printers
        endif !first station
      else ! ps
        if (rlabsize(3).le.0.0) then ! no labe sizes
          write(luscn,'("LABEL01 ERROR: No label sizes specified.")')
          return
        endif
        if (inew.eq.1) then ! start a new file
          if (cprport.eq.'PRINT') then ! temp file name
            cout = labname
          else ! specified file name
            cout = cprport
          endif
          call null_term(cout)
          ierr = copen(fileptr,cout,len(cout))
          if (ierr.eq.0) then
            write(luscn,'("LABELxx - Can''t open output file ",a)') cout
            return
          endif
          nlab=1
        endif ! start a new file
        if (kbatch) then ! get starting row/col
          if (len(cr1).eq.0) then ! default
            if (inew.eq.1) then
              ilabrowin=1
              ilabcolin=1
            else
              ilabrowin=ilabrow
              ilabcolin=ilabcol
            endif
          else ! read them
            read(cr1,*,err=992) ilabrowin
992         read(cr2,*,err=993) ilabcolin
993         continue
          endif ! default/read them
          if (ilabrowin.lt.1.or.ilabrowin.gt.rlabsize(3).or.
     .        ilabcolin.lt.1.or.ilabcolin.gt.rlabsize(4)) then
            write(luscn,9991) ilabrowin,ilabcolin
            return
          endif
          if (inew.eq.0.and.
     .       ilabrowin.lt.ilabrow.or.(ilabrowin.eq.ilabrow.and.
     .       ilabcolin.lt.ilabcol)) inewpage=1
          ilabrow=ilabrowin
          ilabcol=ilabcolin
        elseif (clabtyp .eq. "DYMO") then
          ilabrow=1
          ilabcol=1
          continue
        else ! interactive
910       continue
          write(luscn,'(a)')
     >      " Enter row and column of first label 0 to quit "
          if (inew.eq.1) then
            write(luscn,'(" default is 1,1 ? ",$)')
          else
            write(luscn,'(" default is row ",i2," column ",i2," ? ",$)')
     .      ilabrow,ilabcol
          endif
          read(luusr,'(a)') response
          if (response(1:1).eq.'0') return
          if (response(1:1).eq.' ') then ! default
            if (inew.eq.1) then
              ilabrow=1
              ilabcol=1
            else
C             leave it alone
            endif
          else ! read values
            read (response,*,err=994) ilabrowin,ilabcolin
994         if (ilabrowin.lt.1.or.ilabrowin.gt.rlabsize(3).or.
     .          ilabcolin.lt.1.or.ilabcolin.gt.rlabsize(4)) then ! invalid
              write(luscn,9991) ilabrowin,ilabcolin
              goto 910
            else ! valid
              if (inew.eq.1) then ! new file starting
                ilabrow=ilabrowin
                ilabcol=ilabcolin
                inewpage=0
              else ! continuing
                if (ilabrowin.lt.ilabrow.or.(ilabrowin.eq.ilabrow.and.
     .              ilabcolin.lt.ilabcol)) then ! check
                  if (kbatch) then ! force new page
                    inewpage=1
                    ilabrow=ilabrowin
                    ilabcol=ilabcolin
                  else ! ask
                    write(luscn,'(" Next available row would be ",i2,
     .              ". Row ",i2," will force a new page of labels."/
     .              " Is this correct  (Y,N default Y) ? ",$)')
     >                 ilabrow,ilabrowin
                    read(luusr,'(a)') response
                    response(1:1) = upper(response(1:1))
                    if (response(1:1).eq.'Y') then ! take it
                      inewpage=1
                      ilabrow=ilabrowin
                      ilabcol=ilabcolin
                    else ! try again
                      goto 910
                    endif ! take it/try again
                  endif ! force/ask
                else ! take it
                  ilabrow=ilabrowin
                  ilabcol=ilabcolin
                endif ! check/take it
              endif ! new/continue
            endif ! invalid/valid
          endif ! default/read
        endif ! batch/get starting row/col
      endif ! laser-epson/ps

C 1. First initialize counters.  Read the first observation,
C    and initiate the main loop.

      iob=0
      ierr=0
      do i=1,max_stn
	cstn(i)=" "
      end do
      do iob=1,Nobs
        cbuf=cskobs(iskrec(iob))
        ilen=trimlen(cbuf)

C 2. Unpack the observation, calculate the stop time.
C If this is a new tape, we might have a full buffer for typing
C the labels.  If the count is up, type out labels.
C Remember the start time of this observation.
C Remember the stop time in any case.
C
C CHECK FOR PRINTING OF LABELS BEFORE PROCESSING OBSERVATION.
C THIS IS TO GUARANTEE ALL THE LABELS WILL BE PRINTED, EVEN
C IF THE LAST OBSERVATION DOES NOT INCLUDE THE CURRENT STATION.
C
         CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,
     .         LFREQ,IPAS,LDIR,IFT,LPRE,
     .         IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,
     .         NSTNSK,LSTN,LCABLE,
     .         MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
C
C Preset ISTNSK = 0 in case of EOF, this simplifies the
C logic in "process this observation".
        ISTNSK=0
        call ckobs(csname,cstn,nstnsk,cfreq,isor,istnsk,icod)

        IF (ISOR.EQ.0.OR.ICOD.EQ.0) GOTO 900
C
        IF (ISTNSK.NE.0.OR.Iob.eq.nobs.OR.cbuf(1:1).EQ."$") THEN ! process
          IF(ISTNSK.NE.0)
     .    CALL TMADD(IYR,IDAYR,IHR,iMIN,ISC,IDUR(ISTNSK),IYR2,IDAYR2,
     .               IHR2,iMIN2,ISC2)
          IDIR=+1
          IF (ISTNSK.NE.0)  THEN
            IF (LDIR(ISTNSK).EQ.HHR) IDIR=-1
          ENDIF
          KNEW=.TRUE.
          IF(ISTNSK.NE.0) then
C           if (ks2) then
C             knew = ift(istnsk).eq.0.and.ipas(istnsk).eq.0
            if (idir.ne.0) then
              KNEW = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .        IDIRP,IFTOLD)
            else
              knew = .false.
            endif
          endif
C         Force new tape logic when starting a schedule.
          if (iob.eq.1 .or. iob.eq. nobs) knew=.true.

! If this is the last scan, then the ending time is the end of last scan of this station.
          if (iob .eq. nobs) then
            IY2(NOUT) = mod(IYR2,100)
            IH2(NOUT) = IHR2
            IM2(NOUT) = iMIN2
            ID2(NOUT) = IDAYR2
          endif ! one of ours
C
          IF (KNEW) THEN !NEW TAPE
            IF (NOUT.GE.NLAB.OR.Iob.eq.nobs.or.cbuf(1:1).EQ."$") then !type a row
                if(nout .eq. 0) nout=1
                write(luscn, '(i2,2(2x,i3,"-",i2.2,":",i2.2))')
     >           ntape,id1(1),ih1(1),im1(1), id2(1),ih2(1),im2(1)
              if (.not.klabel_ps) then ! laser or Epson

                CALL BLABL(LUprt,NOUT,cEXPER,cSTNNA(ISTN),cSTCOD(ISTN),
     >            IY1,ID1,IH1,IM1,iy2,ID2,IH2,IM2,ILABROW,
     .            cprttyp,clabtyp,cprport)
                NOUT = 0
                ILABROW=ILABROW+1            !increment vertical label position
                IF (ILABROW.GT.8) ILABROW=ILABROW-8  !reset to top of page
              else ! postscript
                ipsy1=mod(iy1(1),100)
                ipsd1=id1(1)
                ipsh1=ih1(1)
                ipsm1=im1(1)
                ipsy2=mod(iy2(1),100)
                ipsd2=id2(1)
                ipsh2=ih2(1)
                ipsm2=im2(1)

                if(clabtyp .eq. "DYMO") then
                  ilabrow=1
                  ilabcol=1
                endif
                write(ctape_num,'("Tape ",i2)') ntape
                call make_pslabel(fileptr,cstnna(istn),cstcod(istn),
     >           cexper,clabtyp,ctape_num,
     .          ipsy1,ipsd1,ipsh1,ipsm1,ipsy2,ipsd2,ipsh2,ipsm2,
     .          inew,rlabsize,ilabrow,ilabcol,inewpage)
                ilabcol=ilabcol+1
                if (ilabcol.gt.rlabsize(4)) then
                  ilabcol=1
                  ilabrow=ilabrow+1
                  if (ilabrow.gt.rlabsize(3)) then
                    ilabrow=1
                    inewpage=1
                  endif
                endif
                NOUT = 0
              endif
            END IF !type a row
C
            IF (iob .eq. nobs .OR. cbuf(1:1).EQ."$") GOTO 900
            NOUT = NOUT + 1
            NLABPR = NLABPR + 1
            IY1(NOUT) = mod(IYR,100)
            ID1(NOUT) = IDAYR
            IH1(NOUT) = IHR
            IM1(NOUT) = iMIN
c         IS1(NOUT) = ISC
C         NOB(NOUT) = 0
           ntape=ntape+1
          END IF !new tape
C
        if (istnsk.ne.0) then ! one of ours
          IY2(NOUT) = mod(IYR2,100)
          IH2(NOUT) = IHR2
          IM2(NOUT) = iMIN2
c         IS2(NOUT) = ISC2
          ID2(NOUT) = IDAYR2
C         NOB(NOUT) = NOB(NOUT)+1
          IPASP = IPAS(ISTNSK)
         if (ks2) then ! S2 or not
          iftold = ift(istnsk)+idur(istnsk)
          else
          IFTOLD = IFT(ISTNSK) + IFIX(IDIR*(ITEARL(istn)+IDUR(ISTNSK))
     .     *speed(icod,istn))
           endif ! S2 or not
          IDIRP = IDIR
        endif ! one of ours
        ENDIF !process this observation
      ENDDO !loop on observations

900   continue
      if (klabel_ps) then
         ierr=cclose(fileptr,clabtyp)  !close file, add showpage if necessary.
      else
        IF (clabtyp.eq.'LASER+BARCODE_CARTRIDGE'
     .        .or.cprttyp.eq.'FILE') THEN !close laser printer
          WRITE(luprt,'(a)') CHAR(27)//'&l6D'//CHAR(27)//'(8U'//
     >      CHAR(27)//'(s3T'// char(13)
        ENDIF
C if pcode is 1 (one station) or 3 (last station) then close file
        IF (PCODE.EQ.1.OR.PCODE.EQ.3) THEN
          if(clabtyp.eq.'LASER+BARCODE_CARTRIDGE'.or.
     >         cprttyp.eq.'FILE') then
            write(luprt,'(a)') char(12) ! FORM FEED
          endif
          close(luprt)
          call prtmp(0)
        endif
      endif
C
990   IF (IERR.NE.0) WRITE(LUSCN,"(' ERROR ',I3,' READING FILE')") IERR
      WRITE(LUSCN,"(i2, '  LABELS PRINTED FOR ',A)")nlabpr,csTNNA(ISTN)

      RETURN
      END
