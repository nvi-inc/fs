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
      subroutine lxsum
C
C         SUMMARY COMMAND C#870115:05:32#
C
C LXSUM - The SUMMARY command produces a one line listing for each
C         observation consisting of the start time & footage count,
C         the tape number, stop time & footage count, ONSOURCE status,
C         & whether any serious CHEKR errors were encountered.
C
C MODIFICATIONS:
C
C    DATE     WHO  DESCRIPTION
C    820326   KNM  SUBROUTINE CREATED
C
C    820416   KNM  THE SUMMARY COMMAND HAS THE CAPABILITY TO BE WRITTEN
C                  INTO AN OUTPUT FILE IF A FILE NAME WAS SPECIFIED IN
C                  THE OUTPUT COMMAND.
C
C    820513   KNM  A NEW SUMMARY COMMAND WAS IMPLEMENTED.  THIS COMMAND
C                  READS THE $SKED SECTION OF A SCHEDULE FILE & MAKES
C                  SURE THAT EVERY OBSERVATION APPEARS IN THE LOG.  IF
C                  AN OBSERVATION IS MISSING FROM THE LOG, THEN LOGEX
C                  OUTPUTS A SUMMARY LINE THAT INDICATES THAT ALL THE
C                  INFORMATION IS MISSING.
C
C    820607   CAK  LXSUM HAS BEEN CHANGED FROM A SUBROUTINE TO A
C                  SEGMENT PROGRAM OF LOGEX. ALL CALLING ARGUMENTS
C                  HAVE BEEN PLACED INTO COMMON.
C
C    820818   KNM  ALL SUMMARY OUTPUT IS WRITTEN OUT BY CALLING LXWRT.
C
C    871130   LEF  Changed back to subroutine and added CDS.
C
C INPUT VARIABLES:
C
C OUTPUT VARIABLES:
C
      integer*2 lnewso(8)
C       - Contains the new source name.
C
C
C COMMON BLOCKS USED:
C
      include '../include/fscom.i'
C
      include 'lxcom.i'
C
C SUBROUTINE INTERFACES:
C    CALLING SUBROUTINES:
C      LOGEX - Main program.
C
C    CALLED SUBROUTINES:
C      File manager package routines.
C      LNFCH utilities.
C      LXOPN - Open file.
C      REDSK - Read the schedule file until the $SKED section is
C              reached.
C      READT - Get next observation from $SKED section.
C      READL - Get SUMMARY data from next observation from log file.
C      LXSCM - Compare schedule & log file sources & start times.
C      LXWRT - Writes out LOGEX data.
C
C LOCAL VARIABLES:
C
      logical kmatch
C        - A flag that indicates whether we have a matching schedule &
C          log observation.
C
      logical khuh
C      - true if the log run-id is screwy
C
      integer*2 ibufsk(80)
C        - Buffer for schedule file.
C
      dimension ireg(2),iparm(2),ival(2)
C        - Registers for reading; parameters from GTPRM
C        - REG, PARM - two word variables equiv
C
      equivalence (reg,ireg(1)),(parm,iparm(1)),(value,ival(1))
C
      integer*2 lsn(4)
C        - Contains the schedule source name.
C
      integer*2 lsum(25), lrun(40), lnewsn
      integer*2 star(2)
      integer ilsft,ileft
C
C     data lsum/48,'*summary of                  for                '/
      data lsum/48,2H*s,2Hum,2Hma,2Hry,2H o,2Hf ,2H  ,2H  ,2H  ,2H  ,
     .2H  ,2H  ,2H  ,2H  ,2H f,2Hor,2H  ,2H  ,2H  ,2H  ,2H  ,2H  ,2H  ,
     .2H  /
C      data lrun/78,'*run-id    source        ',
C     .'    tape #  feet     start       ',
C     .'stop    feet  status'/
      data lrun/78,2H*r,2Hun,2H-i,2Hd ,2H  ,2H  ,2H  ,
     .2Hso,2Hur,2Hce,2H  ,2H  ,2H  ,
     .2H t,2Hap,2He ,2H# ,2H f,2Hee,2Ht ,
     .2H  ,2H  ,2H  ,2Hst,2Har,2Ht ,2H  ,
     .2H  ,2H  ,2H s,2Hto,2Hp ,2H  ,2Hfe,2Het,2H  ,2Hst,2Hat,2Hus/
C     data star/1,'*'/
      star(1) = 1
      call char2hol('*',star(2),1,1)
C
C INITIALIZED VARIABLES:
C
      data iskbw/80/
      data lnewsn/2H$$/
      data nsum/78/
C
C
C  **************************************************************
C
C  1. Initialize SUMMARY variables.
C
C  **************************************************************
C
C
      call ifill_ch(lsourn,1,16,' ')
      call ifill_ch(lnewso,1,16,' ')
      call ifill_ch(lsft,1,5,' ')
      call ifill_ch(left,1,5,' ')
      call ifill_ch(lsouon,1,8,' ')
      call ifill_ch(ltapen,1,8,' ')
      call ifill_ch(ltapen,3,1,'-')
      call ifill_ch(lsn,1,8,' ')
      call ifill_ch(ibufsk,1,160,' ')
      call ifill_ch(jbuf,1,100,' ')
      if (ikey.eq.12) then
        ierr=0
        call fmprewind(idcbsk,ierr)
        call po_put_c("LXSUM - SKSUMMARY temporarily disabled")
        goto 600
      endif
      kmatch=.true.
      khuh=.false.
      call char2hol('$$',lnewsn,1,2)
      iout=0
      ilen=0
C
C
C ***********************************************************
C
C 2. Check to see if the SKED SUMMARY has been specified.
C    If so, read down to $SKED section.
C
C ***********************************************************
C
C
      ilc = iflch(logna,20)
      ic = iscn_ch(logna,1,ilc,'.')-1
      if (ic.lt.0) ic = ilc
      lch=jchar(logna,ic)
      lstid=lch*o'400'+o'40'
      if (ikey.eq.9) goto 200
      call redsk(ibufsk,iskbw)
      if (icode.eq.-1) goto 600
C
C
C *********************************************************************
C
C 3. Write out the SUMMARY headers. Obtain the source, run id, start
C    time, station id, etc. that the station participates in by
C    reading the schedule file.
C
C *********************************************************************
C
C
200   continue 
      call ichmv(lsum(2),13,logna,1,16)
      call ichmv(lsum(2),34,lstatn,1,8)
      idum=lsum(1)
      call lxwrt(lsum(2),idum)
      idum=star(1)
      call lxwrt(star(2),idum)
      idum=lrun(1)
      call lxwrt(lrun(2),idum)
      idum=star(1)
      call lxwrt(star(2),idum)
      call char2hol(' ',l6,1,1)
300   continue 
      if (ikey.eq.9) goto 400
C
C     Get next schedule entry
C
      call readt(ibufsk,iskbw,lstid,lsn,iyr,idayr,ihr,min,isc,idur,nstn)
      if (icode.eq.-1) goto 600
C
C
C ****************************************************************
C
C 4. Get the SUMMARY data for the next observation from the log.
C
C ****************************************************************
C
C
      if (ilen.eq.-1) goto 420
400   continue
      if (kmatch) then
        goto 410
      else
        goto 420
      end if
410   continue
      call readl(lnewso,lnewsn,lstid)
      if (icode.eq.-1.or.lstend.eq.-1) goto 600
      if (ikey.eq.9) goto 430
420   continue 
      call lxscm(lsn,idayr,ihr,min,isc,idur,kmatch,khuh)
      if (khuh.and.ilen.ne.-1) goto 410
C
C
C ***************************************************************
C
C 5. Here the SUMMARY output is written. Check to see if the
C    observation was missing.  If it was missing fill in
C    the variables to indicate a missing schedule observation
C    from the log.
C
C ***************************************************************
C
C
430   continue 
      call ifill_ch(jbuf,1,100,' ')
      if (ikey.eq.12) then
        call ib2as(idayr,jbuf,1,o'40000'+o'400'*2+3)
        call ifill_ch(jbuf,4,1,'-')
        call ib2as(ihr,jbuf,5,o'40000'+o'400'+2)
        call ib2as(min,jbuf,7,o'40000'+o'400'+2)
      else
        if (itcntl.ne.-1) then
          call ib2as(ilrday,jbuf,1,o'40000'+o'400'*2+3)
          call ifill_ch(jbuf,4,1,'-')
          call ib2as(ilrhrs,jbuf,5,o'40000'+o'400'+2)
          call ib2as(ilrmin,jbuf,7,o'40000'+o'400'+2)
        else
          call ifill_ch(jbuf,4,1,'-')
        endif
      endif
      if(kmatch) then
        call ichmv(jbuf,10,lsourn,1,16)
        call ichmv(jbuf,27,ltapen,1,8)
        ilsft = lsft
        call ib2as(ilsft,jbuf,36,o'40000'+o'400'*5+5)
        if (isld.eq.0) then
          call ifill_ch(jbuf,47,1,'.')
        else          
          call ib2as(isly,jbuf,42,o'40000'+o'400'*4+4)
          call ifill_ch(jbuf,46,1,'.')
          call ib2as(isld,jbuf,47,o'40000'+o'400'*2+3)
          call ifill_ch(jbuf,50,1,'.')
          call ib2as(islhr,jbuf,51,o'40000'+o'400'+2)
          call ifill_ch(jbuf,53,1,':')
          call ib2as(islmin,jbuf,54,o'40000'+o'400'+2)
          call ifill_ch(jbuf,56,1,':')
          call ib2as(islsec,jbuf,57,o'40000'+o'400'+2)
        endif
        if (ield.eq.0) then
          call ifill_ch(jbuf,63,1,'-')
        else
          call ib2as(ielhr,jbuf,60,o'40000'+o'400'+2)
          call ifill_ch(jbuf,62,1,':')
          call ib2as(ielmin,jbuf,63,o'40000'+o'400'+2)
          call ifill_ch(jbuf,65,1,':')
          call ib2as(ielsec,jbuf,66,o'40000'+o'400'+2)
          ileft=left
          call ib2as(ileft,jbuf,69,o'40000'+o'400'*5+5)
        endif
        call ichmv(jbuf,75,lstat,1,6)
      else
        call ifill_ch(jbuf,21,1,'-')
        call ichmv(jbuf,10,lsn,1,16)
        call ifill_ch(jbuf,42,1,'-')
        call ifill_ch(jbuf,52,1,'-')
        call ifill_ch(jbuf,62,1,'-')
        call ifill_ch(jbuf,69,1,'-')
        call ifill_ch(jbuf,76,1,'-')
      end if
      call lxwrt(jbuf,nsum)
      nlout=nlout+1
      if (ikey.eq.9.and.ilen.eq.-1) goto 600
      if (ikey.ne.12) goto 300
      if (ilen.ge.0) goto 300
      ilrday=999
      ilrhrs=99
      ilrmin=99
      goto 300
C
C
C *****************************************************************
C
C 6. Return to LOGEX.
C
C *****************************************************************
C
C
600   ilxget=0
C
      return
      end


