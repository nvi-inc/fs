      program logex
C 
C  LOGEX - A PROGRAM TO EXAMINE THE FIELD SYSTEM LOGS 
C 
C  MODIFICATIONS: 
C 
C     DATE     WHO  DESCRIPTION 
C     800910   KNM  SUMMARY AND STRING COMMAND ADDED
C 
C     810204   KNM  LOGEX WAS DIVIDED UP INTO A MAIN PROGRAM LOGEX, 
C                   PRCCM, AND MCOM.
C 
C     810724   KNM  SUMMARY COMMAND WAS MODIFIED. THE COMMAND NOW 
C                   CONSISTS OF THE SOURCE NAME, START, & STOP TIME 
C                   OF THE OBSERVATION, AND THE TAPE NUMBER.  A 
C                   HEADER LABEL WAS ADDED TO THE SUMMARY COMMAND 
C                   WHICH INDICATES THE LOG NAME AND STATION.  A
C                   HEADER LABEL WAS ADDED WHICH GIVES THE LOG NAME 
C                   AND STATION WHEN A SUCCESSFUL OPEN IS PERFORMED 
C                   ON THE LOG FILE.  SUBROUTINE LXDAY WAS CREATED TO 
C                   TO DETERMINE WHETHER THE LOG DAY HAS CHANGED. 
C                   IF THE LOG DAY HAS CHANGED, A HEADER LABEL IS 
C                   WRITTEN INDICATING THIS.
C 
C     810803   KNM  TYPE COMMAND WAS ADDED TO PRCCM.
C 
C     810810   KNM  THE <COMMAND>=? WAS CHANGED TO <COMMAND>
C 
C     811001   KLI  Add non-interactive mode for SUMMARY command
C                   The correct schedule sequence is :
C                   RU,LOGEX,<user LU>,<output LU>,<2-char log namr>, 
C                            <cart>,<output namr>,<cart>,<SU>,<1-char 
C                            station code>
C 
C     820114   KNM  The non-interactive mode for the SUMMARY command
C                   was further modified.  The Goddard SUMMARY version
C                   utilizes the output file.  The list of CHEKR errors 
C                   was appended to the Goddard SUMMARY.  The day of
C                   log is pick up in the start & stop times of each
C                   observation.  Subroutine LXDAY is no longer 
C                   required.  The Haystack SUMMARY version remains 
C                   intact.  The correct schedule sequence is:
C                   RU,LOGEX,<user LU>,<output LU>,<2-char log namr>, 
C                            <cart>,<output namr>,<cart>,<SU or SH>,
C                            <1-char station code>
C 
C                            SU - Goddard SUMMARY version 
C                            SH - Haystack SUMMARY version
C 
C     820405   KNM  The main program LOGEX was divided up into
C                   subroutines.  The functions that the main program 
C                   performed previously are now done by LXOPN, LXTIM,
C                   LXGET, & LXIST, LXSUM, & LXPLT. The non-interactive 
C                   mode correct schedule sequence is:
C 
C                   RU,LOGEX,<user LU>,<output LU>,<2-char log namr>, 
C                            <log cart>,<SU>,<output file name> 
C 
C                   SU - SUMMARY Command
C 
C                   A test was added to determine whether the Field 
C                   System was running. 
C 
C     820416   KNM  The OUTPUT command replaced the LU commmand.  The 
C                   user may specify any logical unit for the output
C                   to be displayed or an output file name in the form
C                   of <Name>:<secu. code>:<cartridge>
C 
C     820513   KNM  The SCHEDULE SUMMARY command was implemented. This
C                   command reads the $SKED section of a schedule file
C                   & makes sure that every observation appears in the
C                   log. If an observation is missing from the log, 
C                   then LOGEX outputs a SUMMARY line that indicates
C                   that condition. 
C 
C     820607   CAK  The recent modifications to LOGEX have significantly
C                   increased its size. Consequently, LOGEX has been
C                   divided into 4 segments. All calling arguments have 
C                   been put into common. 
C 
C     820909   KNM  LOGEX run string has been changed to the following:
C
C                   RU,LOGEX,<user LU>,<command file namr>
C
C                   Subroutine LXCMD has been added to handle the read-
C                   ing of the command file.  A command file may be used
C                   non-interactively or interactively by using the
C                   CFILE command.
C
C     901228   GAG  Changed IPGST call to KBOSS call to see if BOSS
C                   is running.
C
C  RESTRICTIONS: Only capable of reading and plotting log entries
C                generated within the Field System.
C
C  REFERENCES: LOGEX: Examining the Logs/Mark III Field System
C                     Documentation
C
C  INPUT VARIABLES:
C
      character*100 cbuf
      character*64 cfile
C
C
C  OUTPUT VARIABLES:
C
C  COMMON BLOCKS USED:
C
      include '../include/fscom.i'
C
      include 'lxcom.i'
C
C
C  DATA BASE ACESSES:
C
C     None
C
C  EXTERNAL INPUT/OUTPUT:
C
C     INPUT VARIABLES:
C 
C     TERMINAL   - IBUF 
C 
C  OUTPUT VARIABLES:
C 
C     TERMINAL   - LINE 
C 
C  SUBROUTINE INTERFACE:
C 
C     CALLED SUBROUTINES & SEGMENTS:
C 
C     File manager package routines 
C     LNFCH routines
C     GETST - Gets a RUN string.
C     PARSE - Allows a program to parse a string into separate
C             parameters. 
C     LXOPN - Open log file.
C     LXCMD - Reads command file.
C     IGTCM - returns command number after checking name in IBUF.
C     LXTIM - Decode specified times.
C     LXIST - LIST command.
C     LXPLT - PLOT command.
C     LXSUM - SUMMARY command.
C     LXPRC - Handles the static commands for LOGEX.
C     LXWRT - Writes out LOGEX data.
C
C
C  LOCAL VARIABLES:
C
      integer fblnk, trimlen
      integer answer, nchar
      character*79 outbuf
      logical kboss
      integer*2 ireg(2),iparm(2),ival(2)
C        - Registers for reading; parameters from GTPRM
C        - REG, PARM - two word variables equiv
C
      equivalence (reg,ireg(1)), (parm,iparm(1)), (value,ival(1))
C
C
C            Command Name       IKEY Number
C
C               OUTPUT              1
C               COMMAND             2
C                 LOG               3
C                LIST               4
C                HELP               5
C               TPLOT               6
C                PARM               7
C                SCALE              8
C               SUMMARY             9
C               STRING             10 
C                TYPE              11 
C              SKSUMMARY           12 
C                PLOT              13 
C                SKED              14 
C               CFILE              15 
C                SIZE              16 
C 
C  INITIALIZED VARIABLES: 
C 
C 
C  **************************************************************** 
C 
C  1. Get the Run string and test for interactive/non-interactive 
C     mode. 
C 
C  **************************************************************** 
C 
C 
C
      call setup_fscom
      call read_fscom
      luusr=6
      ludsp=luusr
      cfile=' '
      call rcpar(1,cfile)
C
C If a parameter was specified, we are in non-interactive mode.
C
      if (cfile.eq.' ') goto 75
C
      nintv=1
      call fmpopen(idcbcm,cfile,ierr,'r',idum)
      if(ierr.lt.0) then
        outbuf='LOGEX20 - error '
        call ib2as(ierr,answer,1,5)
        call hol2char(answer,1,5,outbuf(17:))
        nchar = trimlen(outbuf) +1
        outbuf(nchar:)=' opening command file ' // cfile
        call po_put_c(outbuf)
        goto 100
      endif
C
C Check to see if the Field System is running.
C
75    continue
      call rcpar(2,lognc)
      if(lognc.eq.' ') then
         if(kboss()) then
            call fs_get_llog(illog)
            call hol2char(illog,1,8,lognc)
            call lxopn
        endif
      else
         call lxopn
      endif
      if (nintv.eq.1) goto 150
C
C  ****************************************************************
C
C  2. If we are in the interactive mode, issue the prompt to get a
C     command from the user. This is the return point after the
C     execution of a command in the interactive mode.
C
C  ****************************************************************
C
C
100   write(6,802)
802   format(1x,"? ",$)
      nintv=0
      icmd=0
      icode=0
      lstend=0
      call fmpclose(idcbcm,ierr)
      iblen=256
      call ifill_ch(ibuf,1,iblen*2,' ')
      read(5,801) cbuf
801   format(a)
      nchar=trimlen(cbuf)
      call char2hol(cbuf, ibuf,1,nchar)
      if (nchar.eq.0) goto 100
      call upper(ibuf,1,nchar)
      nchar=fblnk(ibuf,1,nchar)
C
C LOGEX is terminated if an EX or :: is typed
C
      if(ichcm_ch(ibuf,1,'EX').eq.0 .or.
     &   ichcm_ch(ibuf,1,'ex').eq.0 .or.
     &   ichcm_ch(ibuf,1,'::').eq.0) goto 500
C
C
C  ****************************************************************
C
C  3. Read the command file if we are in non-interactive mode or
C     the CFILE command was issued. This is the return point
C     after the execution of command file entry.
C 
C  **************************************************************** 
C 
C 
150   if (nintv.eq.1.or.icmd.eq.1) call lxcmd
      if (nintv.eq.1.and.il.lt.0) goto 500 
      if (icmd.eq.1.and.il.lt.0) goto 100
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) ieq = nchar+1 
C 
C 
C  **************************************************************** 
C 
C  4. Call IGTCM to return command number and store it into IKEY
C 
C  **************************************************************** 
C 
C 
      ikey = igtcm(1,ieq-1) 
      if (ikey.gt.0) goto 200
      if (ikey.eq.0) call po_put_c('LOGEX30 - unrecognized command')
      if (ikey.eq.-1) call po_put_c('LOGEX40 - ambiguous command') 
      goto 100
C 
C 
C  **************************************************************** 
C 
C  5. LOGEX tests the IKEY number to determine whether it is an 
C     active or static command.  The active commands are the LIST,
C     PLOT, and SUMMARY commands.  The remaining commands are 
C     considered static commands. 
C 
C  **************************************************************** 
C 
C 
200   goto(300,300,300,210,300,210,300,300,210,300,300,210,210,300,300, 
     .300),ikey 
210   call lxtim
      if (icode.eq.-1) goto 100
220   goto(100,100,100,230,100,250,100,100,260,100,100,260,250,100),ikey
230   call lxist
      goto 270 
C 
C Call LXPLT segment for PLOT or TPLOT command
C 
250   call lxplt
8004  continue
      goto 270 
C 
C Call LXSUM segment for SKSUMMARY or SUMMARY Command 
C 
260   call lxsum
270   if(lstend.ne.-1) goto 280 
      call po_put_c(' *end of listing')
280   if (icmd.eq.1.or.nintv.eq.1) goto 150
      if (ilen.ge.0.or.icode.eq.-1.or.lstend.eq.-1) goto 100 
      outbuf=' *LOGEX50 - end of log file ' 
      call hol2char(logna,1,10,outbuf(29:))
      call po_put_c(outbuf)
      goto 100
C 
C Call LXPRC for static processing commands.
C 
300   call lxprc
8006  continue
      if (icmd.eq.1.or.nintv.eq.1) goto 150
      goto 100
C
C
C  ****************************************************************
C
C  6. Close all files. Off all segments.
C
C  *****************************************************************
C
C
500   call fmpclose(idcb,ierr)
      call fmpclose(jdcb,ierr)
      call fmpclose(idcbsk,ierr)
      call fmpclose(idcbcm,ierr)
C
      call po_put_c('logex done')
      end
