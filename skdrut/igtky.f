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
      integer FUNCTION IGTKY(LINSTQ,ITYPE,LFUNC)
C
C   IGTKY determines the key word typed in using minimum-matching
C
      INCLUDE '../skdrincl/skparm.ftni'
C
C  INPUT VARIABLES:
      integer*2 LINSTQ(*)
C               - input string from user, word 1=length
      integer itype
C     ITYPE - type of key word wanted:
C
C     OUTPUT VARIABLES:
         integer*2 lfunc
C        IGTKY  - function return code
C        LFUNC  - 2-letter keyword code
C        Returned Codes are the following:
C        -1 = ambiguous (more than 1 match within a type)
C         0 = unrecognized
C TYPE
C type 1 for new obs command
C  1         ST = START date/time
C  1         CB = CABLE
C  1,2       SU = SUBNET
C  1,2       DU = DURATION
C  1,2       ID = IDLE
C  1,2       CA = CALIBRATION
C  1,2       FR = FREQUENCY
C  1,2       PR = PREOB procedure name
C  1,2       MI = MIDOB procedure name
C  1,2       PO = POSTOB procedure name
C type 2 for parameters
C  2         MO = MODULAR time between runs
C  2         LO = LOOKAHEAD time
C  2         MN = MINIMUM  time between runs
C  2         CH = CHANGE time for tape
C  2         EX = EXPERIMENT name
C  2         SY = SYNCHRONIZE tapes
C  2         SP = SETUP
C  2         PA = PARITY
C  2         PP = PREPASS
C  2         SO = SOURCE
C  2         HD = HEAD
C  2         PF = PRFLAG
C  2         TP = TAPETM
C  2         MB = MINBETWEEN
C  2         MT = MIDTP
C  2         SD = SUNDIStance
C  2         MS = MINSCAN
C  2         XS = MAXSCAN
C  2         VS = VSCAN
C  2         MD = MODSCAN
C  2         WI = WIDTH
C  2         VI = VIS
C  2         CO = CONFIRM
C  2         CR = CORSYNCH
C  2         SA = SNR auto/ask
C  2         TE = EARLY  
C  2         SM = MINSUBNET
C  2         BR = BARREL
C  2         DE = DESCRIPTION (experiment description)
C  2         PI = SCHEDULER (scheduler's name)
C  2         TC = target correlator
C  2         ST = nominal start time
C  2         EN = nominal end time
C  2         JA = start java parameters program
C  2         GT = get parameters from java program
C  2         PS = POSTPASS 
C  3         TA = TAPE shift
C  3         TI = TIME shift
C  3         ID = IDLE for CHECK
C  4         SE = SELECT sources/stations/freqs
C  4         LI = LIST sources/stations/freqs
C  5         ON = ON selection
C  5         OF = OFF selection
C  6         PA = PART for baseline command
C  7         PL = plot sources
C  8         TO = TOTAL for muvis command
C  9         LJ = laser jet printer type
C 10         EX = EXPANDED summary
C 11         PR = PRINTER unit
C 11         SC = SCREEN unit
C 11         AP = APPEND
C 11         OV = OVERWRITE
C 12         FT = FEET parameter for XLIST
C 12         AZ = AZEL parameter for XLIST, only az and el
C 12         DU = DUR parameter for XLIST
C 12         SX = SNR parameter for XLIST 
C 12         MX = MAXIMUM for XLIST
C 12         FL = FLUX for observed flux for XLIST
C 12         A2 = AZEL including HA for XLIST
C 12         ON = ON for XLIST
C 12         OF = OFF for XLIST
C 13         not used
C for TAPE motion type command
C 14         AD - ADAPTIVE tape motion type
C 14         CO - CONTINUOUS tape motion type
C 14         SS - START&STOP tape motion type
C 14         DY - DYNAMIC tape motion type
C These for SUM are also for SITEVIS
C 15         LI = LINE display for SUM
C 15         XY = azel plot for SUM
C 15         PO = polar plot for SUM
C 15         CO = coverage for SUM
C 15         DI = distance for SUM
C 15         EL = el/time plot for SUM
C 15         FI = output plot file by SUM
C 15         BA = BASELINE display for SUM
C 15         ST = STATS display for SUM
C 15         HI = HIST(OGRAM) display for SUM
C 15         HS = Histogram for SNR
C For the parameter list command
C 16         SN = SNR parameters
C 16         PR = PROCEDURE parameters
C 16         GE = GENENRAL parameters
C 16         AL = ALL parameters
C 16         NO = for the NOtes file
C For SNR command
C 17         MR = MARGIN parameter for SNR
C For the 
C 18         AU = AUTO, MA = MAN 
C 18         ON = ON, OF = OFF
C 18         SU = SUB, AL = ALL
C 18         YE = YES, NO = NO
C For WH command
C 19         FU = FULL for WHATSUP
C 19         MI = MINIMUM for WHATSUP
C 19         NO = NO for WHATSUP
C For RESULT command
C 20         CV = COVARIANCE for RESULT
C 20         CO = COVERAGE for RESULT
C 20         CR = CORRELATION for RESULT
C 20         FE = FE for RESULT (formaal errors)
C For OP command
C 21         LI = LIST for OP
C 21         SE = SET for OP
C 21         GO = GO for OP
C For XNEW command
C 22         ON/OFF, SEFD, SNR, BASE, FLUX
C For TTYPE (tape type) command
C 23         TH = THICK
C 23         TN = THIN
C 23         SH = SHORT
C 23         LO = LOW
C 23         HI = HIGH
C 23         SL = SLP (S2 speed)
C 23         LP = LP (S2 speed)
C For CATALOG command
C 24         ST = START
C 24         GT = GET
C 
C     CALLING SUBROUTINES: PRSET, NEWOB, CHCMD, xxSEL, SNRCM
C                          SUMPR, NEXTPR, XLCMD, XNCMD
C
C  History
C 970314 nrv New, replaces old version.
C 970317 nrv Add "A2" for azelha in XLIST
C 970317 nrv Add continuous, adaptive, and start&stop for TAPE motion type.
C 970326 nrv Add keywords for XNEW command
C 970423 nrv Add back in "on" and "off" for XLIST
C 980629 nrv Add dynamic tape motion type.
C 990412 nrv Add XS for MAXSCAN.
C 990520 nrv Add DESCRIPTION, SCHEDULER, and CORRELATOR.
C 990524 nrv Add THICK, THIN for tape type, HIGH, LO for density.
C 991108 nrv Add START and GET for CATALOG command.
C 991118 nrv Add START and END for parameters.
C 000125 nrv Add SLP and LP for S2 speeds.
C 000326 nrv Add JAVA and GET for parameters program.
C 000605 nrv Remove DYNAMIC tape motion. Add AUTO and SCHEDULED for
C            tape allocation type.
C 001003 nrv Add SHORT as a tape type.
C 020227 nrv Add NOTES as a parameter type.
C 021011 nrv Add POSTPASS parameter
C
C   LOCAL VARIABLES
      integer numcmd,ic,ifunc1,ifunc,nccmd
C
      character*20 ckeyin ! input keyword
      character*20 ckey(134) ! keywords to match
      character*2 ccode(134)  ! corresponding 2-letter code
      integer ivalid(134) ! type for which it is valid
      integer i,nch
      character*1 lq
C
C  Initialized
      data numcmd/134/
      data ckey/'START','CABLE','SUBNET','DURATION','IDLE',
     .'CALIBRATION','FREQUENCY','PREOB','MIDOB','POSTOB',
     .
     .'SUBNET','DURATION','IDLE',
     .'CALIBRATION','FREQUENCY','PREOB','MIDOB','POSTOB',
     .'MODULAR','LOOKAHEAD','MINIMUM','CHANGE','EXPERIMENT','EARLY',
     .'MINSUBNET','SYNCHRONIZE','SETUP','PARITY','PREPASS','BARREL',
     .'SOURCE','PRFLAG','HEAD','TAPETM','MINBETWEEN','MIDTP','SUNDIS',
     .'MINSCAN','VSCAN','MODSCAN','WIDTH','VIS','CONFIRM','CORSYNCH',
     .'SNR','MAXSCAN','DESCRIPTION','SCHEDULER','CORRELATOR',
     .'START','END','JAVA','GET','POSTPASS',
     .
     .'TAPE','TIME','IDLE',
     .'SELECT','LIST',
     .'ON','OFF',
     .'PART', 
     .'PLOT',
     .'TOTAL',
     .'LASER',
     .'EXPAND',
     .'PRINT','SCREEN','APPEND','OVERWRITE',
     .'FEET','AZEL','DUR','SNR','MAX','FLUX','HA','ON','OFF',
     .
     .'CONTINUOUS','ADAPTIVE','START&STOP',
     .
     .'LINE','XYAZEL','POLAZEL','COVERAGE','DISTANCE','EL','AZ',
     .'FILE','BASELINE','STATS','HIST','SNR',
     .
     .'SNR','PROCEDURE','GENERAL','ALL','NOTES',
     .'MARGIN',
     .'AUTO','MANUAL','ON','OFF','SUB','ALL','YES','NO',
     .'FULL','MINIMUM','NO',
     .'COVARIANCE','CORRELATION','FE',
     .'LIST','SET','GO',
     .'ON','OFF','FLUX','SNR','SEFD','BASE',
     .
     .'THICK','THIN','SHORT','HIGH','LOW','SLP','LP',
     .
     .'START','GET',
     .
     .'AUTO','SCHEDULED'/
C
      DATA ccode/'ST','CB','SU','DU','ID','CA','FR','PR','MI','PO',
     .
     .'SU','DU','ID','CA','FR','PR','MI','PO',
     .'MO','LO','MN','CH','EX','TE','SM','SY','SP','PA','PP',
     .'BR','SO','PF','HD','TP','MB','MT','SD','MS','VS','MD','WI',
     .'VI','CO','CR','SA','XS','DE','PI','TC','ST','EN','JA','GT',
     .'PS',
     .
     .'TA','TI','ID',
     .'SE','LI',
     .'ON','OF',
     .'PA',
     .'PL',
     .'TO',
     .'LJ',
     .'EX',
     .'PR','SC','AP','OV',
     .'FT','AZ','DU','SX','MX','FL','A2','ON','OF',
     .'CO','AD','SS',
     .'LI','XY','PO','CO','DI','EL','AZ','FI','BA','ST','HI','HS',
     .'SN','PR','GE','AL','NO',
     .'MR',
     .'AU','MA','ON','OF','SU','AL','YE','NO',
     .'FU','MI','NO',
     .'CV','CR','FE',
     .'LI','SE','GO',
     .'ON','OF','FL','SN','SE','BA',
     .'TH','TN','SH','HI','LO','SL','LP',
     .'ST','GT',
     .'AU','SC'/

      DATA ivalid/10*1,44*2,3*3,2*4,2*5,6,7,8,9,10,4*11,9*12,
     .3*14,12*15,5*16,17,8*18,3*19,3*20,3*21,6*22,7*23,2*24,2*25/
C
C
C  1. Find the command in the list of commands with minimum matching.
C    Two matches is error -1, none is error 0.

      nccmd=linstq(1)
      if (nccmd.gt.20) return ! can't handle it
      call hol2upper(linstq(2),nccmd)
      call hol2char(linstq(2),1,nccmd,ckeyin)
C
      ic = 1
      ifunc=0
      do while (ic.le.numcmd.and.ifunc.eq.0)
        if (ckeyin(1:nccmd).eq.ckey(ic)(1:nccmd).and.
     .      itype.eq.ivalid(ic)) then ! match
          ifunc=ic
        endif
        ic=ic+1
      enddo
      if (ifunc.eq.0) goto 900
      ifunc1=ifunc ! save the match found

C 2. Now look for a second match.

      ic=ifunc1+1
      ifunc=0
      do while (ic.le.numcmd.and.ifunc.eq.0)
        if (ckeyin(1:nccmd).eq.ckey(ic)(1:nccmd).and.
     .      itype.eq.ivalid(ic)) then ! second match
          ifunc=ic
        endif
        ic=ic+1
      enddo
      if (ifunc.eq.0) then ! only 1 found
        ifunc=ifunc1
      else ! duplicate
        ifunc=-1
      endif

900   IF (IFUNC.GT.0) call char2hol(ccode(ifunc),lfunc,1,2)
      IGTKY = IFUNC
      RETURN
      END
