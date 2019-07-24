      subroutine ucmo(ip)
C  receiver control   <910326.1634>
C
C     UCMO controls the S-X receiver and requests a reading
C
C     INPUT VARIABLES:
C
      dimension ip(1)
C               - parameters from QUIKR
C        IP(1)  - class number of input parameter buffer
C        IP(2-5)- not used
C
C     OUTPUT VARIABLES:
C
C        IP(1) - CLASS
C        IP(2) - # RECS
C        IP(3) - ERROR
C        IP(4) - who we are
C
C 2.2.   COMMON BLOCKS USED
C
      include '../include/fscom.i'
C
C 2.5.   SUBROUTINE INTERFACE:
C
C     CALLED SUBROUTINES: UC2MA, MATCN, UCDMO
C
C 3.  LOCAL VARIABLES
C
C     LA - hex address
C     IC - code index for name checking
C     IDCAL - delay cal heater on/off
C     ILOH - LO heater ON/OFF
C     IBOX - box heater ON/OFF
C     ICAL - noise cal on/off
      dimension ifamp(3)
C           - IF amps on/off
C        NCHAR  - number of characters in uffer
C        ICH    - character counter
      integer*2 ibuf(20)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension ireg(2) 
      integer get_buf,ichcm_ch
      character cjchar
C               - registers from EXEC calls 
C 
      equivalence (reg,ireg(1)) 
C 
C  4.  CONSTANTS USED
      parameter (ilen=40)
C 
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:  CREATED 830610 AT MOJAVE
C          NRV 840509 MADE CHANGES FOR NEW VERSION
C          LAR 880426  REMOVED CODE NAMES TO (RXDEF
C 
C     1. If class buffer contains command name with "=" then we have
C     parameters to set the UC.  If only the command name is present, 
C     then read the UC. 
C 
      iclcm = ip(1) 
      ierr = 0
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C                   If no parameters, go read UC
      if (cjchar(ibuf,ieq+1).ne.'?') goto 140
      ip(4) = o'77'
      call ucdmo(ip,iclcm)
      return
C
140   continue
      if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700
C
C
C     2. Get parameter as follows:
C              UC=<channel>,<dcal>,<LOH>,<box>,<S>,<X>,<K>,<cal>
C     where <channel> may be a hex address or a code word.
C           <dcal> is ON or OFF for delay cal heater
C           <LOH> is ON or OFF for box heater
C           <box> is ON or OFF for box heater
C           <S>,<X>,<K> are ON or OFF for IF amps
C           <cal> is ON, OFF (normal) or OON, OOF (override)
C
      ich = 1+ieq
      ic1 = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
C                     Get channel, ASCII
      nch = ich-ic1-1
      if (nch.gt.0) goto 210
C             There is no default for the channel 
      ierr = -101 
      goto 990
210   if (cjchar(ibuf,ic1).ne.'*') goto 211
      la = iadcst 
C             Pick up old address from common 
      goto 220
C 
211   if (nch.gt.2) goto 212
C     First check for an address
      call char2hol('00',la,1,2)
      if (nch.eq.2) idumm1 = ichmv(la,1,ibuf,ic1,2) 
      if (nch.eq.1) idumm1 = ichmv(la,2,ibuf,ic1,1) 
      if (ia22h(la).ne.-1) goto 220
C         This is a valid hex address
C     Now check for a code word
212   do 213 ic=1,ncodes
        if (ichcm(ibuf,ic1,lcode(1,ic),1,nch).eq.0
     .  .and. iflch(lcode(1,ic),6).eq.nch) goto 214
213     continue
      ierr = -201
C             No match found for code word
      goto 990
214   ic = ic-1
      la = ih22a(ic)
C
C     2.2 Delay cal heater. ON or OFF.
C
220   call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 222
      if (cjchar(parm,1).eq.'*') idcal=idchst
C                     Pick up old value from common
      if (cjchar(parm,1).eq.',') idcal=1
C                     Default is on
      goto 225
222   idcal=-1
      if (ichcm_ch(parm,1,'on').eq.0) idcal=1
      if (ichcm_ch(parm,1,'off').eq.0) idcal=0
      if (idcal.ge.0) goto 225
      ierr = -202
      goto 990
C
C     2.2 LO heater. ON or OFF.
C
225   call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 227
      if (cjchar(parm,1).eq.'*') iloh=ilohst
C                     Pick up old value from common
      if (cjchar(parm,1).eq.',') iloh=1
C                     Default is on
      goto 230
227   iloh=-1
      if (ichcm_ch(parm,1,'on').eq.0) iloh=1
      if (ichcm_ch(parm,1,'off').eq.0) iloh=0
      if (iloh.ge.0) goto 230
      ierr = -203
      goto 990
C
C     2.3 Box heaters.  ON or OFF.
C
230   call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 232
      if (cjchar(parm,1).eq.'*') ibox=ibxhst
C                     Pick up old value from common
      if (cjchar(parm,1).eq.',') ibox=1
C                     Default is A controller on
      goto 240
232   ibox=-99
      if (ichcm_ch(parm,1,'on').eq.0) ibox=1
      if (ichcm_ch(parm,1,'off').eq.0) ibox=0
      if (ibox.ne.-99) goto 240
      ierr = -204
      goto 990
C
C     2.4 IF amplifiers, S-X-K are ON or OFF.
C
240   do 249 i=1,3
        call gtprm(ibuf,ich,nchar,0,parm,ierr)
        if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 242
        if (cjchar(parm,1).eq.'*') ifamp(i)=ifamst(i)
C                     Pick up old value from common
        if (cjchar(parm,1).eq.',') ifamp(i)=1
C                     Default is on
        goto 249
242     ifamp(i)=-1
        if (ichcm_ch(parm,1,'on').eq.0) ifamp(i)=1
        if (ichcm_ch(parm,1,'off').eq.0) ifamp(i)=0
        if (ifamp(i).ne.-1) goto 249
        ierr = -204-i
        goto 990
249     continue
C
C     2.5 Noise cal, ON or OFF or EXT, or OON or OOFF for override.
C
250   call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 252
      if (cjchar(parm,1).eq.'*') ical=lswcal
C                     Pick up old value from common
      if (cjchar(parm,1).eq.',') ical=0
C                     Default is off
      goto 300
252   ical=-99
      if (ichcm_ch(parm,1,'on').eq.0) ical=1
      if (ichcm_ch(parm,1,'off').eq.0) ical=0
      if (ichcm_ch(parm,1,'oon').eq.0) ical=-1
      if (ichcm_ch(parm,1,'ooff').eq.0) ical=-2
      if (ichcm_ch(parm,1,'ext').eq.0) ical=2
      if (ical.ne.-99) goto 300
      ierr = -208
      goto 990
C
C
C     3. Finally, format the buffer for the controller.
C
300   ibuf(1) = 0
      call char2hol('uc',ibuf(2),1,2)
      call uc2ma(ibuf(3),ical,0,idcal,iloh,ibox,ifamp,la)
C                   Format the data part of the buffer
      iclass = 0
      call put_buf(iclass,ibuf,-12,2hfs,0)
      nrec = 1
      call uc2ma(ibuf(3),ical,1,idcal,iloh,ibox,ifamp,la)
C                      Send second message to effect transition
      call put_buf(iclass,ibuf,-12,2hfs,0)
      nrec = 2
      goto 400
C
C
C     4. Now plant these values into COMMON.
C     Finally schedule BOSS to request that MATCON gets the data.
C
400   continue
      iadcst = la
      lswcal = ical
      idchst = idcal
      ilohst = iloh
      ibxhst = ibox
      ifamst(1) = ifamp(1)
      ifamst(2) = ifamp(2)
      ifamst(3) = ifamp(3)
C 
      goto 800
C 
C 
C     5.  This is the read device section.
C     Request one type of data. 
C 
500   ibuf(1) = -1
      call char2hol('uc',ibuf(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C 
C 
C     6. This is the test/reset device section. 
C 
600   ibuf(1) = 6 
      call char2hol('uc',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C 
C 
C     7. This is the alarm query and reset request. 
C 
700   ibuf(1) = 7 
      call char2hol('uc',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C 
C 
C     8. All MATCN requests are scheduled here, and then UCDMO called.
C 
800   call run_matcn(iclass,nrec)
      call rmpar(ip)
      call ucdmo(ip,iclcm)
      return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('st',ip(4),1,2)
      return
      end 
