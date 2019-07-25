      subroutine rxmo(ip)
C  receiver control   <910326.1621>
C 
C     RXMO controls the S-X receiver and requests a reading 
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
C     CALLED SUBROUTINES: RX2MA, MATCN, RXDMO 
C 
C 3.  LOCAL VARIABLES 
C 
C     LA - hex address
C     IC - code index for name checking 
C     IDCAL - delay cal heater on/off 
C     IBOX - box heater off/A/B 
C     ICAL - noise cal on/off 
      dimension ifamp(3)
C           - IF amps on/off
C        NCHAR  - number of characters in uffer 
C        ICH    - character counter 
      integer*2 ibuf(20),la
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls 
C 
      character cjchar
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
C     NRV 921020 Added fs_get calls

C 
C     1. If class buffer contains command name with "=" then we have
C     parameters to set the RX.  If only the command name is present, 
C     then read the RX. 
C 
      iclcm = ip(1) 
      ierr = 0
      ichold = -99
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   continue
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C                   If no parameters, go read RX
      if (cjchar(ibuf,ieq+1).ne.'?') goto 140
      ip(4) = o'77' 
      call rxdmo(ip,iclcm)
      return
C 
140   continue
      if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600 
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700 
C 
C 
C     2. Get parameter as follows:
C              RX=<channel>,<dcal>,<box>,<S>,<X>,<K>,<cal>
C     where <channel> may be a hex address or a code word.
C           <dcal> is ON or OFF for delay cal heater
C           <box> is A, B, or OFF for box heater
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
      idum=ichmv(la,1,iadcrx,1,2)
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
212   continue
C      write(6,101) rxncodes
C101   format("rxmo: rxncodes=",i5/)
C      write(6,102) (rxlcode(i,1),i=1,3),(rxlcode(j,2),j=1,3)
C102   format("rxmo: rxlcode(n,1&2)=",3a2,2x,3a2/)
      do 213 ic=1,rxncodes  
        if (ichcm(ibuf,ic1,rxlcode(1,ic),1,nch).eq.0 
     .  .and. iflch(rxlcode(1,ic),6).eq.nch) goto 214
213     continue
      ierr = -201 
C             No match found for code word
      goto 990
214   ic = ic-1 
      idum=ichmv(la,1,ih22a(ic),1,2)
C 
C     2.2 Delay cal heater. ON or OFF.
C 
220   call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 222 
      if (cjchar(parm,1).eq.'*') idcal=idchrx
C                     Pick up old value from common 
      if (cjchar(parm,1).eq.',') idcal=1 
C                     Default is on 
      goto 230
222   idcal=-1
      if (ichcm_ch(parm,1,'on').eq.0) idcal=1
      if (ichcm_ch(parm,1,'off').eq.0) idcal=0
      if (idcal.ge.0) goto 230
      ierr = -202 
      goto 990
C 
C     2.3 Box heaters.  A, B, or OFF. 
C 
230   call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 232 
      if (cjchar(parm,1).eq.'*') ibox=ibxhrx 
C                     Pick up old value from common 
      if (cjchar(parm,1).eq.',') ibox=1  
C                     Default is A controller on
      goto 240
232   ibox=-99
      if (ichcm_ch(parm,1,'a').eq.0) ibox=1 
      if (ichcm_ch(parm,1,'b').eq.0) ibox=-1
      if (ichcm_ch(parm,1,'off').eq.0) ibox=0 
      if (ibox.ne.-99) goto 240 
      ierr = -203 
      goto 990
C 
C     2.4 IF amplifiers, S-X-K are ON or OFF. 
C 
240   do 249 i=1,3
        call gtprm(ibuf,ich,nchar,0,parm,ierr) 
        if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 242 
        if (cjchar(parm,1).eq.'*') ifamp(i)=ifamrx(i)
C                     Pick up old value from common 
        if (cjchar(parm,1).eq.',') ifamp(i)=1
C                     Default is on 
        goto 249
242     ifamp(i)=-1 
        if (ichcm_ch(parm,1,'on').eq.0) ifamp(i)=1 
        if (ichcm_ch(parm,1,'off').eq.0) ifamp(i)=0 
        if (ifamp(i).ne.-1) goto 249
        ierr = -203-i 
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
      ierr = -207
      goto 990
C
C
C     3. Finally, format the buffer for the controller.
C
300   ibuf(1) = 0
      call char2hol('rx',ibuf(2),1,2)
      call rx2ma(ibuf(3),ical,0,idcal,ibox,ifamp,la)
C                   Format the data part of the buffer
      iclass = 0
      call put_buf(iclass,ibuf,-12,'fs','  ')
      nrec = 1
      call rx2ma(ibuf(3),ical,1,idcal,ibox,ifamp,la)
C                      Send second message to effect transition 
      call put_buf(iclass,ibuf,-12,'fs','  ')
      nrec = 2
      goto 400
C 
C 
C     4. Now plant these values into COMMON.
C     Finally schedule BOSS to request that MATCON gets the data. 
C 
400   continue
      call fs_get_icheck(icheck(19),19)
      ichold = icheck(19)   
      icheck(19) = 0
      call fs_set_icheck(icheck(19),19)
      idum=ichmv(iadcrx,1,la,1,2)
      lswcal = ical 
      idchrx = idcal
      ibxhrx = ibox 
      ifamrx(1) = ifamp(1)
      ifamrx(2) = ifamp(2)
      ifamrx(3) = ifamp(3)
C 
      goto 800
C 
C 
C     5.  This is the read device section.
C     Request one type of data. 
C 
500   ibuf(1) = -1
      call char2hol('rx',ibuf(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      nrec = 1
      goto 800
C 
C 
C     6. This is the test/reset device section. 
C 
600   ibuf(1) = 6 
      call char2hol('rx',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      nrec = 1
      goto 800
C 
C 
C     7. This is the alarm query and reset request. 
C 
700   ibuf(1) = 7 
      call char2hol('rx',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      nrec = 1
      goto 800
C
C
C     8. All MATCN requests are scheduled here, and then RXDMO called.
C
800   call run_matcn(iclass,nrec)
      call rmpar(ip)
      if (ichold.ne.-99) then
        icheck(19) = ichold
        call fs_set_icheck(icheck(19),19)
      endif
      if (ichold.ge.0) then
        icheck(19) = mod(ichold,1000)+1
        call fs_set_icheck(icheck(19),19)
      endif
      call rxdmo(ip,iclcm)
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qb',ip(4),1,2)
      return
      end
