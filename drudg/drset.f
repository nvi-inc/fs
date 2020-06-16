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
      SUBROUTINE DRSET(LINSTQ)
      implicit none  !2020Jun15 JMGipson automatically inserted.
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
      parameter (MaxPr=49)
      character*15 listPr(MaxPr)
      character*2  listPrShort(MaxPr)

      data listPr/
     > "ALL_BL_GOOD",
     > "BARREL",    "CALIBRATION","CHANGE",     "CONFIRM",
     > "CORRELATOR","CORSYNCH",   "DEBUG",      "DESCRIPTION",
     > "DURATION",
     > "EARLY",     "END",        "EXPERIMENT", "FILLIN",
     > "FREQUENCY",
     > "GET",       "HEAD",       "IDLE",       "JAVA",
     > "LOOKAHEAD", "MAXSCAN",    "MIDOB",      "MIDTP",
     > "MINBETWEEN","MINIMUM",    "MINSCAN",    "MINSUBNET",
     > "MARK6_OFF",
     > "MODSCAN",   "MODULAR",    "NOREWIND",
     > "PARITY",     "POSTOB",
     > "POSTPASS",  "PREOB",      "PREPASS",    "PRFLAG",
     > "SCHEDULER", "SETUP",      "SNR",        "SOURCE",
     > "START",     "SUBNET",     "SUNDIS",     "SYNCHRONIZE",
     > "TAPETM",    "VIS",        "VSCAN",      "WIDTH"/

      data listPrShort/
     >"AG",
     >"BR","CA","CH","CO",
     >"TC","CR","DG","DE","DU",
     >"TE","EN","EX","FI","FR",
     >"GT","HD","ID","JA",
     >"LO","XS","MI","MT",
     >"MB","MN","MS","SM",
     >"M6",
     >"MD","MO","NR","PA","PO",
     >"PS","PR","PP","PF",
     >"PI","SP","SA","SO",
     >"ST","SU","SD","SY",
     >"TP","VI","VS","WI"/
C
C  History
C 970401 nrv New. Copied from sked's PRSET, leaving only those
C                 parameters drudg is interested in.
C 021010 nrv Add POSTPASS y or n parameter.
! 2004Jul16  JMGipson rewritten
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
      IDUMMY = ICHMV(LKEYWD,1,LINSTQ(2),IC1,NC)
      ikey = istringminmatch(listpr,MaxPr,ckeywd)
      IF  (IKEY.EQ.0) THEN  !invalid
! Don't issue an error message because it could be a parameter that sked
! knows about but not drudg.
!        write(luscn,9110) ckeywd
!9110    format('DRSET01 - ',a24,' is not a valid parameter name.')
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
      ckeywd=" "
      nc = ic2-ic1+1
      idummy = ichmv(lkeywd,1,linstq(2),ic1,nc)

      if(ckey .eq. "DE") then
        return          !ignore rest of line.
      else IF  (ckey.eq.'PS') then
        call capitalize(ckeywd)
        if(ckeywd .eq. "Y") then
           kpostpass=.true.
        else if(ckeywd .eq. "N") then
           continue
        else
          write(luscn,'(" DRSET26: Error: POSTPASS must be Y or N")')
        endif
      else if(ckey .eq. "TC") then
        ccorname=ckeywd

C  Numerical values
      elseif  (ckey.eq.'SP'.OR.ckey.eq.'PA'.OR.ckey.eq.'SO'.OR.
     .         ckey.eq.'HD'.OR.ckey.eq.'TP'.OR.ckey.eq.'TE'.or.
     >         ckey.eq.'CH'.or.ckey .eq.'M6') then
        INUM = IAS2B(LINSTQ(2),IC1,IC2-IC1+1)
        IF  (INUM.lt.0) THEN
          write(luscn,'("DRSET04 - Invalid parameter value.")')
          RETURN
        END IF
        IF (ckey.eq.'SP') THEN
          ISETTM = INUM
        else if(ckey .eq. 'M6') then
          imark6_off=inum
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
      else if(ckey .eq. 'SF') then   !srcfloor takes two parameters. Read 2nd.
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      endif

C  5.  Test to see if there is more to the line which we need to
C      decode.  If so, go back to parse some more.

900   IF ((LINSTQ(1)-ICH).GT.0) GOTO 100
C
      RETURN
      END
