      subroutine spars(ias,ifc,iec,lnames,nnames,lproc1,nproc1, 
     .   lproc2,nproc2,lparm,nparm,itype,ierr,itlis,index,iclass)
C 
C   SPARS parses a SNAP command 
C 
C     INPUT VARIABLES:
C 
      integer*2 ias(1)
C               - array holding command 
C***NOTE*** IAS IS MODIFIED BY EXPANDING PARAMETERS 
C        IFC    - first character of command in IAS 
C        IEC    - last character of command in IAS
C****NOTE**** IEC IS MODIFIED IF IAS IS EXPANDED
      dimension lnames(13,1)
      integer*4 lproc1(4,1),lproc2(4,1) 
C               - lists of recognized functions and procedures
C        NNAMES - number of entries in LNAMES array 
C        NPROC1 - number of entries in LPROC1 array 
C        NPROC2 - number of entries in LPROC2 array 
      dimension lparm(1)
C     - parameter to be inserted into command 
C     NPARM - number of chars in LPPARM 
C 
C     OUTPUT VARIABLES: 
C 
C     ITYPE - type of command returned from SPARS 
C                   !_ (wait for time)
C                   !R (wait for time and establish it as reference time) 
C                   !* (wait for time + reference time) 
C                   !! (wait for time + now)
C                   _F (function) 
C                   _P (procedure from list 1)
C                   _Q (procedure from list 2)
C                   !F (wait for function)
C                   !P (wait for procedure) 
C                   !Q (wait for procedure) 
C                   _C (comment)
C        IERR   - error code, 0=all OK, > 0 soft error, < 0 hard error
C             0 - OK
C            -1 - error in characters following a ! 
C            -2 - two many characters in command
C            -3 - more than 12 characters in function or procedure name 
C            -4 - unrecognized name (not a function or procedure) 
C            -5 - standard format time field error
C            -6 - <not used>
C            -7 - date or time out or range 
C            -8 - alternate format time field error 
C            -9 - no date allowed in time field 
C           -10 - attempt to schedule over New Year's eve - you should
C                 be at a party instead!!!
C           -11 - stop time occurs before start time
C           -12 - more than 100 chars in expanded command 
C        INDEX  - index into LNAMES, LPROC1, or LPROC2 which
C                 corresponds to ITYPE
C        ICLASS - class # for buffer which holds entire command 
      dimension itlis(3,3)
C      ITIME - time list parameters 
C              3 words each: start, period, stop. 
C                   ITIME(1,1) - start (IYR-1970)*1024 + IDAY 
C                   ITIME(2,1) - start HR*60+MIN
C                   ITIME(3,1) - start SEC*100 + MSEC/10
C                   ITIME(1,2) - period resolution code 
C                              1=msec/100    2=sec   3=min
C                   ITIME(2,2) - period multiplier (value)
C                   ITIME(3,2) - 0
C                   ITIME(1,3) - stop (IYR-1970)*1024 + IDAY
C                   ITIME(2,3) - stop HR*60 + MIN 
C                   ITIME(3,3) - stop SEC*100 + MSEC/10 
C 
C   COMMON BLOCKS USED:  none 
C 
C     CALLING SUBROUTINES: BWORK
C 
C     CALLED SUBROUTINES: GTNAM (hashes, checks out names)
C                         GTTIM (parses time fields)
C                         TMLIS (parses time lists) 
C 
C   LOCAL VARIABLES 
      character char1,char2,cjchar
C
C        ICHAR1,2
C               - character counters
C        ICHARA,B,C
C               - character counters
      dimension ireg(2)
C        REG
C               - registers from EXEC 18 (CLASS I/O)
      integer*2 lbuf(256)
C               - buffer sent to CLASS I/O
C        NCHAR  - number of characters in LBUF
C        CHAR2 - second character in command
C
      equivalence (ireg(1),reg)
C
C
C     1. First initialize all returned parameters.
C
      call char2hol('  ',itype,1,2)
      do 100 i=1,3
        do 100 iz=1,3
          itlis(i,iz) = 0
100     continue
      iclass = 0
      index = 0 
      ierr = 0
C 
      nchar = iec-ifc+1 
      if (nparm.eq.0) goto 200
      idol = iscn_ch(ias,ifc,iec,'$') 
      if (idol.eq.0) goto 200 
      istc=ifc 
      nch=1
      idolnext=idol
      do while(idolnext.ne.0)
         idol=idolnext
         if (nch+nparm+nchar-istc-1.gt.512) then
            ierr = -12
            goto 999
         endif
         nch = ichmv(lbuf,nch,ias,istc,idol-istc)
C                   MOVE THE CHARACTERS UP TO THE $ INTO OUTPUT 
         nch = ichmv(lbuf,nch,lparm,1,nparm) 
C                   MOVE THE PARAMETERS INTO PLACE
         istc=idol+1
         if(idol.ne.iec) then
            idolnext = iscn_ch(ias,istc,iec,'$') 
         else
            idolnext=0
         endif
      enddo
      if (idol.ne.iec) then
        nch = ichmv(lbuf,nch,ias,idol+1,nchar-idol) 
C                   MOVE THE REMAINING CHARACTERS 
C*****NOTE***** HERE WE ARE MODIFYING OUR INPUT PARAMETERS!!
      endif
      iec = nch - ifc 
      idummy = ichmv(ias,ifc,lbuf,1,nch-1)
C 
C  2. Get first character in command.  If it is ", handle comment. 
C     If it is !, handle control command.  If neither, next section.
C 
200   char1 = cjchar(ias,ifc)
C
      if (char1.eq.'"') then       !! WE HAVE A ", I.E. COMMENT.
        call char2hol(' c',itype,1,2)
        goto 999
      endif
C
      if (char1.ne.'!') goto 300
C
C  2.2 We have a !, i.e. control command.
C
      char2 = cjchar(ias,ifc+1)
      if (char2.lt.'a'.or.char2.gt.'z') goto 220
C
C  2.21 We have a letter, i.e. procedure or function name
C
      call gtnam(ias,ifc+1,iec,lnames,nnames,lproc1,nproc1,
     .lproc2,nproc2,ierr,itype,index)
      call char2hol(' ',itype,1,1)
C                   On return from GTNAM, ITYPE has P or F.  We add a !
C                   as the first character, indicating a wait.
      goto 999
C
220   if (char2.lt.'0'.or.char2.gt.'9') goto 230
C
C  2.22 We have a number, i.e. a time. 
C 
      iref = iscn_ch(ias,ifc,iec,'*') 
      if (iref.eq.0) iref = iec+1 
      call gttim(ias,ifc+1,iref-1,0,itlis(1,1),itlis(2,1),
     .           itlis(3,1),ierr) 
      call char2hol('! ',itype,1,2)
      if (iref.eq.iec) call char2hol('!r',itype,1,2)
      goto 999
C 
C  2.23 We have neither number nor letter, could be * or +.
C 
230   if (char2.ne.'*') goto 250 
C 
C  2.24 We have !*.....
C 
      if (iec.gt.ifc+1) goto 240
C 
C  2.25 We have only !*, i.e. establish now as a ref time. 
C 
      call char2hol('!r',itype,1,2)
      itlis(1,1)=-1 
      goto 999
C 
240   if (cjchar(ias,ifc+2).ne.'+') goto 290 
C 
C  2.25 We have !*+<time>
C 
      call char2hol('!*',itype,1,2)
      call gttim(ias,ifc+3,iec,0,itlis(1,1),itlis(2,1),itlis(3,1),ierr) 
      goto 999
C 
250   if (char2.ne.'+') goto 290 
C 
C  2.26 We have !+<time> 
C 
      call char2hol('!!',itype,1,2)
      call gttim(ias,ifc+2,iec,0,itlis(1,1),itlis(2,1),itlis(3,1),ierr) 
      goto 999
C 
290   ierr = -1 
      goto 999
C 
C 
C  3. This is the section which deals with functional, procedural, 
C     commands.  Also reserved words and conditionals.
C     Functional and procedural commands have the format: 
C                   fpfp=p1,p2,p2@t1,t2,t3
C     where fp is the function or procedure name, tested with GTNAM 
C           pn are the parameters, collectively the parameter list
C           tn is the timelist field
C 
C  3.1 First find locations of = and @ signs.  Check first word. 
C 
300   ichara = iscn_ch(ias,ifc,iec,'=')
      if (ichara.eq.0) ichara=iec+1
      icharb=0
      istart=ifc
      do while(icharb.eq.0)
         icharb = iscn_ch(ias,istart,iec,'@')
         if(icharb.eq.0) then
            icharb=iec+1
         else if(icharb.gt.ifc) then
            if(ichcm_ch(ias,icharb-1,'\\').eq.0) then
               do i=icharb,iec
                  call pchar(ias,i-1,jchar(ias,i))
               enddo
               iec=iec-1
               istart=icharb
               icharb=0
            endif
         endif
      enddo
      ichar1 = min0(ichara,icharb,iec+1)
C                   Use first special character position
C
      call gtnam(ias,ifc,ichar1-1,lnames,nnames,lproc1,nproc1,
     .lproc2,nproc2,ierr,itype,index)
      if (ierr.ne.0) goto 999
C
C  3.2 Second section handles parameter list, which follows =.
C      All characters from start to @ are sent to class buffer,
C      including parameters.
C
      nchar = icharb - ifc
      if (nchar.gt.512) then
        ierr = -2
        goto 999
      endif
      idummy = ichmv(lbuf,1,ias,ifc,nchar)
C
      call put_buf(iclass,lbuf,-nchar,'fs','  ')
C
C  3.3 TIME LIST SECTION, CHARACTERS FOLLOWING THE @.
C
      if (icharb.ne.iec+1) then
        call tmlis(ias,icharb+1,iec,itlis,ierr) 
      endif
C 
999   continue
      return
      end 
