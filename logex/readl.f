      subroutine readl(lnewso,lnewsn,lstid)
C 
C READL - Gets SUMMARY data from next observation from the log file.
C 
C MODIFICATIONS:
C 
C    DATE     WHO  DESCRIPTION
C    820513   KNM  SUBROUTINE CREATED 
C    820818   KNM  COMMENTS ARE WRITTEN OUT BY CALLING LXWRT
C 
C INPUT VARIABLES:
C 
      integer*2 lnewso(8), lnewsn 
C       - Contains new source name. 
C 
C    LSTID - Station identifier 
C    LNEWSN - A flag which indicates whether a new source has been
C             encountered.
C 
C COMMON BLOCKS USED: 
C 
      include 'lxcom.i'
C 
C    CALLING ROUTINES:
C 
C      LXSUM - SUMMARY command. 
C 
C    CALLED SUBROUTINES:
C 
C      LXWRT - Writes out LOGEX data
C      LNFCH Utilities
C 
C LOCAL VARIABLES:
C
      integer ichcm_ch
      character cjchar
C 
      integer*2 ireg(2),iparm(2),ival(2),ibuf2(256)
C        - Registers for reading; parameters from GTPRM 
C        - REG, PARM - two word variables equiv 
C 
      save oldformat
      equivalence (reg,ireg(1)),(parm,iparm(1)),(value,ival(1)) 
      data oldformat/-1/
C 
C     ICHK - Indicates whether a CHEKR error has been encountered.
C     IET - Indicates whether an stop time has been encountered.
C     ISLEW - Indicates whether a slewing response has been encountered.
C     IST - Indicates whether a start time has been encountered.
C 
C 
C  ***************************************************************
C
C  1. Initialize for a new source.
C
C  ***************************************************************
C
C
      call ifill_ch(lsourn,1,16,' ')
      call ifill_ch(lsouon,1,8,' ')
      call ifill_ch(lsft,1,6,' ')
      call ifill_ch(lsft,1,1,'-')
      call ifill_ch(left,1,6,' ')
      call ifill_ch(left,1,1,'-')
      call ifill_ch(lstat,1,6,' ')
      call ichmv_ch(lstat,1,'O')
      call ichmv_ch(lstat,2,'E')
      isld=0
      islhr=0
      islmin=0
      islsec=0
      ield=0
      ielhr=0
      ielmin=0
      ielsec=0
      ilrday=0
      ilrhrs=0
      ilrmin=0
      ist=-1
      iet=-1
      itcntl=-1
      islew=-1
      ichk=-1
      if (ichcm_ch(lnewsn,1,'$$').ne.0) call ichmv(lsourn,1,lnewso,1,16)
C
C  *************************************************************
C
C  2.  Call LXGET to read a log entry.
C
C  *************************************************************
C
C
100   call lxget
      call mvupper(ibuf2,1,ibuf,1,nchar)
      if (ilen.eq.-1) call ichmv(ltapen,1,ltapn,1,8)
      if (icode.eq.-1.or.lstend.eq.-1.or.ilen.eq.-1) goto 1200
C
C
C  ************************************************************
C
C  3. Check for any comments in the log. If the entry is a com-
C     ment, write it to the terminal.  If we are in non-
C     interactive mode, write it to the output file.
C
C  ************************************************************
C
C
      if(logformat.ne.oldformat) then
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
            ildch=21
C not Y10K compliant
            ifrst=22
         endif
         oldformat=logformat
      endif
      if (cjchar(ibuf2,ifrst).ne.'"') goto 300
      call ifill_ch(jbuf,1,100,' ')
      call ifill(jbuf,1,1,o'42')
      call ichmv(jbuf,2,lstid,1,1)
      call ichmv(jbuf,4,ibuf2,1,ilen)
      ncom=ilen+3
      call lxwrt(jbuf,ncom)
      goto 100
C
C
C  *********************************************************
C
C  4. Check for a source command. If we have a new source,
C     save it and return to LXSUM to write out the data.
C
C  *********************************************************
C
C
300   continue
      if (ichcm_ch(ibuf2,ifrst,'SOURCE=').ne.0) goto 350
      ich = ifrst+7
      call gtprm(ibuf2,ich,nchar,0,parm,id)
C
C  Make sure there are some characters in the source name
C  before trying to move them.  Accept a maximum of 8
C  characters.
C
      if (ichcm_ch(lnewsn,1,'$$').ne.0) goto 310
      if (ich-(ifrst+8).le.0) goto 100
      call ichmv(lnewso,1,ibuf2,ifrst+7,min0(16,ich-(ifrst+8)))
      call ichmv(lsourn,1,ibuf2,ifrst+7,min0(16,ich-(ifrst+8)))
      call char2hol('  ',lnewsn,1,2)
      goto 100
310   call ifill_ch(lnewso,1,16,' ')
      if (ich-(ifrst+8).gt.0)
     &     call ichmv(lnewso,1,ibuf2,ifrst+7,min0(16,ich-(ifrst+8)))
      goto 1200
C
350   if (ichcm_ch(lsourn,1,'                ').eq.0) goto 100
C
C
C  ************************************************************
C
C  5. Check for the START TIME command characters.
C
C  ************************************************************
C
C
400   if (ichcm_ch(ibuf2,ifrst,'ST=').ne.0) goto 500
      isly=iyear
      isld=ias2b(ibuf2,idyps,3)
      islhr=ias2b(ibuf2,ihrps,2)
      islmin=ias2b(ibuf2,imnps,2)
      islsec=ias2b(ibuf2,iscps,2)
      ist=1
      goto 100
C
C
C  ************************************************************
C
C  6. Check for the tracking status.
C
C  ************************************************************
C
C
 500  continue
      if (ichcm_ch(ibuf2,ifrst,'ONSOURCE/').ne.0) goto 600
      if (ichcm_ch(ibuf2,ifrst+9,'TRACKING').ne.0) goto 510
      call ichmv_ch(lstat,1,'O')
      goto 100
510   if (islew.eq.1.or.iet.eq.1) goto 100
      call ichmv_ch(lstat,1,'o')
      islew=1
      goto 100
C
C
C  ************************************************************
C
C  7. Check for any CHEKR errors.
C
C  *************************************************************
C
C
600   if (ichcm_ch(ibuf2,ifrst,'ERROR CH').ne.0) goto 700
      if (ichk.eq.1) goto 100
      call ichmv_ch(lstat,2,'e')
      ichk=1
      goto 100
C
C
C  ************************************************************
C
C  8. Check for the STOP TIME command characters.
C
C  ************************************************************
C
C
700   if (ichcm_ch(ibuf2,ifrst,'ET').ne.0) goto 800
      ield=ias2b(ibuf2,idyps,3)
      ielhr=ias2b(ibuf2,ihrps,2)
      ielmin=ias2b(ibuf2,imnps,2)
      ielsec=ias2b(ibuf2,iscps,2)
      iet=1
      goto 100
C
C  ************************************************************
C
C  9. Check for a LABEL command characters.
C
C  ************************************************************
C
C
800   if (ichcm_ch(ibuf2,ifrst,'LABEL=').ne.0) goto 900
      call ichmv(ltapen,1,ibuf2,ifrst+6,8)
      call ichmv(ltapn,1,ltapen,1,8)
      goto 100
C
C
C  ************************************************************
C
C  10. Check for a UNLOD command. If we have one, re-initialize
C      the tape number to "$$".
C
C  ************************************************************
C
C
900   if (ichcm_ch(ibuf2,ifrst,'UNLOD').ne.0) goto 1000
      call ichmv(ltapn,1,ltapen,1,8)
      call ifill_ch(ltapen,1,8,' ')
      call ifill_ch(ltapen,3,1,'-')
      goto 100
C
C
C  ************************************************************
C
C  11. Check for tape footage.
C
C  ************************************************************
C
C
1000  if (ichcm_ch(ibuf2,ifrst,'TAPE/').ne.0) goto 1100
      nch=ifrst+5
      call gtprm(ibuf2,nch,nchar,0,parm,ierr)
      call gtprm(ibuf2,nch,nchar,1,parm,ierr)
      if (ist.eq.-1) lsft = iparm(1)
      if (iet.eq.1)  left = iparm(1)
      goto 100
C
C
C  ************************************************************
C
C  12. Check for the time control command. (e.g.!323113715)
C
C  ************************************************************
C
C
1100  continue
      if (cjchar(ibuf2,ifrst).ne.'!') goto 100
      if (ist.eq.1) goto 100
      call gttim(ibuf2,ifrst+1,nchar,0,it1,it2,it3,ierr)
      if(ierr.ne.0) goto 100
      ilrday=mod(it1,1024)
      ilrhrs=it2/60
      ilrmin=mod(it2,60)
      itcntl=1
      goto 100
C
1200  continue
      return
      end
