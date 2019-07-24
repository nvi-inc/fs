      subroutine pe(ip)
C  !tape error rates c#870115:04:38#
C 
C    PE computes tape parity error rates
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C     COMMON BLOCKS USED
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: GTPRM
C 
C    LOCAL VARIABLES
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(20)
      integer*2 ibuf2(10) 
C               - class buffer
C        ILEN    - length of IBUF in chars
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls 
      dimension perr(11)
C      - parity error counts
C     ISYNER - count of synch errors
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 
C    INITIALIZED VARIABLES
      data ilen/40/ 
C 
C    PROGRAMMER: NRV
C     LAST MODIFIED:  810207
C 
C 
C     1. Get the command. 
C 
      iclass = 0
      nrec = 0
      iclcm = ip(1) 
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C                   If no parameters, go read decoder 
      if (cjchar(ibuf,ieq+1).ne.'?') goto 200
      ip(4) = o'77' 
      call pedis(ip,iclcm,perr,isyner)
      return
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C           PERR=<track>,<chan>,<#samples>,<period>,<mode>
C           <track>=track number to decode
C           <chan>=channel A or B 
C           <#samples>=number of samples
C           <period>=time between samples 
C           <mode>=RECord or PLAYback 
C 
C     2.0 TRACK, PARAMETER 1
C 
200   ich = 1+ieq 
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      itrk = -1 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 201 
      if (cjchar(parm,1).eq.'*') itrk = itrper 
      call fs_get_itraka(itraka)
      if (cjchar(parm,1).eq.',') itrk = itraka 
C                   Default to channel A track already set up 
      goto 220
201   if (iparm(1).ge.1.and.iparm(1).le.28) goto 202
      ierr = -201 
      goto 990
202   itrk = iparm(1)
C 
C     2.2 CHANNEL, PARAMETER 2
C 
220   ichan = -1
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') ichan = ichand
      if (cjchar(parm,1).eq.',') ichan = 0 
C                   Default is channel A
      if (cjchar(parm,1).eq.'a') ichan = 0
C                   Channel A 
      if (cjchar(parm,1).eq.'b') ichan = 1
C                   Channel B 
      if (ichan.ne.-1) goto 230 
      ierr = -202 
      goto 990
C 
C     2.3 # SAMPLES, PARAMETERS 3 
C 
230   call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 231 
      if (cjchar(parm,1).eq.'*') ins = insper
      if (cjchar(parm,1).eq.',') ins = 2 
C                   Default number of samples is 1 (no averaging) 
      goto 240
231   ins = iparm(1) 
      if (ins.ge.1.and.ins.le.10) goto 240
      ierr = -203 
      goto 990
C 
C     2.4 TIME BETWEEN SAMPLES, PARAMETER 4 
C 
240   call gtprm(ibuf,ich,nchar,2,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 241 
      if (cjchar(parm,1).eq.'*') tper = tperer 
      if (cjchar(parm,1).eq.',') tper = 0.5
C                   Default time between samples is 0.5 sec 
      goto 250
241   tper = parm 
      if (tper.gt.0.0.and.tper.le.2.0) goto 250 
      ierr = -204 
      goto 990
C 
C     2.5 MODE, PARAMETER 5 
C 
250   call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 251 
      if (cjchar(parm,1).eq.'*') lm = imodpe 
      if (cjchar(parm,1).eq.',') lm = 0
C                   Default mode is REC 
      goto 300
251   lm = -1 
      if (ichcm_ch(parm,1,'play').eq.0) lm = 1 
      if (ichcm_ch(parm,1,'rec').eq.0) lm = 0 
      if (lm.ne.-1) goto 300
      ierr = -205 
      goto 990
C 
C 
C     3. Now plant these values into COMMON.
C 
300   insper = ins
      tperer = tper 
      ichper = ichan
      itrper = itrk 
      imodpe = lm 
      ierr = 0
      goto 990
C 
C 
C     5.  Now we read the device. 
C                   mmDE000000dd
C     where the first "d" has one bit telling the channel,
C     and the second "d" has an "8" for error rates.
C     Then send ">" to transfer control and load the data, then 
C      "/" to read back the data. 
C     First check for the following conditions to insure a valid
C     measure of parity errors: 
C     1) read-after-write mode
C     2) record enabled 
C     3) tape moving, in forward direction
C     4) requested channel is attached to an enabled track
C 
500   continue
      call fs_get_ispeed(ispeed)
      call fs_get_idirtp(idirtp)
      call fs_get_ienatp(ienatp)
      if (imodpe.eq.0.and.ibypas.eq.0.and.ienatp.eq.1.and.ispeed.ne.0.
     . .and.idirtp.eq.1.and.itrken(itrper).eq.1) goto 501 
      if (imodpe.eq.1.and.ibypas.eq.0.and.ispeed.ne.0) goto 501 
      ierr =   00 
      goto 990
C                     Skip out with no error if we can't measure PEs
C 
501   continue
      call fs_get_icheck(icheck(18),18)
      ichold = icheck(18) 
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      ibuf2(1) = 0
      call char2hol('tp',ibuf2(2),1,2)
      if (ichper.eq.0) itraka = itrper  
      call fs_set_itraka(itraka)
      if (ichper.eq.1) itrakb = itrper  
      call fs_set_itrakb(itrakb)
      call fs_get_itraka(itraka)
      call rp2ma(ibuf2(3),ibypas,ieqtap,ibwtap,itraka,itrakb) 
      iclass=0
      call put_buf(iclass,ibuf2,-13,2hfs,0) 
      call run_matcn(iclass,1) 
      call rmpar(ip)
      if (ip(3).lt.0) return
      call clrcl(ip(1)) 
      icheck(18) = ichold 
      call fs_set_icheck(icheck(18),18)
C                   First set up the repro track which was requested. 
C 
      idumm1 = ichmv(ibuf2,5,8h00000008,1,8)
      idumm1 = ichmv(ibuf2,11,ihx2a(ichper),2,1)
C                   Move in the channel bit 
      perr(1) = 0.0 
      do 580 isamp=1,insper+1 
        call susp(1,ifix(tperer*100.0)) 
C                   Suspend between samples and before the first
C                   sample to let the decoding settle down
        ibuf2(1) = 0
        call char2hol('de',ibuf2(2),1,2)
        iclass = 0
        call put_buf(iclass,ibuf2,-12,2hfs,0) 
        ibuf2(1) = 5
        call char2hol('> ',ibuf2(2),1,2)
        call put_buf(iclass,ibuf2,-3,2hfs,0)
        call char2hol('/ ',ibuf2(2),1,2)
        call put_buf(iclass,ibuf2,-3,2hfs,0)
C 
        call run_matcn(iclass,3) 
        call rmpar(ip)
        if (ip(3).lt.0) return
C 
        iclass = ip(1)
        nrec = ip(2)
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
C                   Ignore the first two ACKs 
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
C                   This is the data
        count = 0.0 
        do i=1,6
          ia = ia2hx(ibuf,i+4)
          count = count + ia*16.0**(6-i)
        enddo
        perr(isamp) = count 
        if (isamp.eq.1) isyn1=ia2hx(ibuf,3)*16 + ia2hx(ibuf,4)
C                   If this is the first sample, get the number 
C                   of synch errors 
580     continue
      isyner = ia2hx(ibuf,3)*16+ia2hx(ibuf,4)-isyn1 
C                   Total number of synch errors is difference between
C                   last and first readings.
C 
C     Now set the repro tracks back to what they were.
C     Turn on checking for the tape drive again.
C 
C     IBUF2(1) = 0
C     IBUF2(2) = 2HTP 
C     CALL RP2MA(IBUF2(3),IBYPAS,IEQTAP,IBWTAP,ITRAKA,ITRAKB) 
C     ICLASS=0
C     CALL RMPAR(IP)
C     IF (IP(3).LT.0) RETURN
C     CALL CLRCL(IP(1)) 
C     ICHECK(18) = ICHOLD 
C 
C     Now we can display the results, finally.
C 
      call pedis(ip,iclcm,perr,isyner)
      return
C 
C 
C 
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qj',ip(4),1,2)
      return
      end 
