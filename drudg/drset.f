      SUBROUTINE DRSET(LINSTQ)
C
C   DRSET reads certain parameter values from the $PARAM section
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
! functions
      integer iStringMinMatch
C
C     INPUT VARIABLES:
      integer*2 LINSTQ(*)
C      - input string, length=word 1
C
C   LOCAL VARIABLES
      integer i2long,ichmv,ias2b !functions
      integer is,ich,ic1,ic2,nc,idummy,ikey,inum
      integer*2 LKEYWD(12)

      character*24 ckeywd
      equivalence (lkeywd,ckeywd)
C               - Key word, longest is 22 characters
      character*2 ckey

      integer MaxPr
      parameter (MaxPr=47)
      character*15 listPr(MaxPr)
      character*2  listPrShort(MaxPr)
      integer MaxYN
      parameter (maxyn=2)
      Character*3 listyn(2)
! DATA statements
      data listyn/"YES","NO"/
      data listPr/
     > "BARREL",    "CALIBRATION","CHANGE",     "CONFIRM",
     > "CORRELATOR","CORSYNCH",   "DESCRIPTION","DURATION",
     > "EARLY",     "END",        "EXPERIMENT", "FILLIN",
     > "FREQUENCY",
     > "GET",       "HEAD",       "IDLE",       "JAVA",
     > "LOOKAHEAD", "MAXSCAN",    "MIDOB",      "MIDTP",
     > "MINBETWEEN","MINIMUM",    "MINSCAN",    "MINSUBNET",
     > "MODSCAN",   "MODULAR",    "PARITY",     "POSTOB",
     > "POSTPASS",  "PREOB",      "PREPASS",    "PRFLAG",
     > "SCHEDULER", "SETUP",      "SNR",        "SOURCE",
     > "SRCFLR",    "SRCDIST",
     > "START",     "SUBNET",     "SUNDIS",     "SYNCHRONIZE",
     > "TAPETM",    "VIS",        "VSCAN",      "WIDTH"/

      data listPrShort/
     >"BR","CA","CH","CO",
     >"TC","CR","DE","DU",
     >"TE","EN","EX","FI","FR",
     >"GT","HD","ID","JA",
     >"LO","XS","MI","MT",
     >"MB","MN","MS","SM",
     >"MD","MO","PA","PO",
     >"PS","PR","PP","PF",
     >"PI","SP","SA","SO",
     >"SF","--",                      !"SD" is used by SUNDIS
     >"ST","SU","SD","SY",
     >"TP","VI","VS","WI"/
C
C  History
C 970401 nrv New. Copied from sked's PRSET, leaving only those
C                 parameters drudg is interested in.
C 021010 nrv Add POSTPASS y or n parameter.
C
C
C  1. Now parse the input string, getting each key word and its value.
C
      ICH = 1
100   continue
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN
        RETURN
      END IF
      NC = IC2-IC1+1
      ckeywd=" "
      IDUMMY = ICHMV(LKEYWD,3,LINSTQ(2),IC1,NC)
      ikey = istringminmatch(ckeywd,listpr,MaxPr)
      IF  (IKEY.EQ.0) THEN  !invalid
        write(luscn,9110) ckeywd
9110    format('DRSET01 - ',a24,' is not a valid parameter name.')
        RETURN
      END IF  !invalid
      ckey=listprshort(ikey)

! get argument of keyword.
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      if (ic1.eq.0) then
         write(luscn,'("DRSET03 - Missing parameter value.")')
         return
      endif
C
C  Character values
      if(ckey .eq. "DE") then
        return          !ignore rest of line.
      else IF  (ckey.eq.'PS') then
        nc = ic2-ic1+1
        ckeywd=" "
        idummy = ichmv(lkeywd,3,linstq(2),ic1,nc)
        ikey=istringMinMatch(ckeywd,listyn,MaxYN)
        IF  (ikey.EQ.0) THEN
          WRITE(LUSCN,9441)
9441      FORMAT(' PRSET26 - Error: POSTPASS must be Y or N')
        ELSE
          Kpostpass=listyn(ikey).eq."YES"
        END IF
C  Numerical values
      elseif  (ckey.eq.'SP'.OR.ckey.eq.'PA'.OR.ckey.eq.'SO'.OR.
     .         ckey.eq.'HD'.OR.ckey.eq.'TP'.OR.ckey.eq.'TE'.or.
     >         ckey.eq.'CH') then
        INUM = IAS2B(LINSTQ(2),IC1,IC2-IC1+1)
        IF  (INUM.lt.0) THEN
          write(luscn,'("DRSET04 - Invalid parameter value.")')
          RETURN
        END IF
        IF (ckey.eq.'SP') THEN
          ISETTM = INUM
        ELSE IF (ckey.eq.'CH') THEN
          ITCTIM = INUM                    !tape change time.
        ELSE IF (ckey.eq.'PA') THEN
          IPARTM = INUM
        ELSE IF (ckey.eq.'SO') THEN
          ISORTM = INUM
        ELSE IF (ckey.eq.'HD') THEN
          IHDTM = INUM
        ELSE IF (ckey.eq.'TP') THEN
          ITAPTM = INUM
        else if (ckey.eq.'TE') then
          do is=1,nstatn
            itearl(is) = inum
          enddo
        endif
      endif
 
C  5.  Test to see if there is more to the line which we need to
C      decode.  If so, go back to parse some more.
 
900   IF ((LINSTQ(1)-ICH).GT.0) GOTO 100
C
      RETURN
      END
