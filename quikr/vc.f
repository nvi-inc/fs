      subroutine vc(ip,ivcn)
C  video converter control <910324.0011>
C 
C   VC controls the video converters
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer
C        IP(2-5)- not used
C        IVCN   - video converter index number, which one.
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
C     CALLING SUBROUTINES:
C 
C     CALLED SUBROUTINES: GTPRM
C 
C 3.  LOCAL VARIABLES 
C 
C        FREQ   - frequency specified, must be < 500MHz 
C        IBW    - bandwidth code
C        ITP    - TP code 
C        IATN   - attenuator code 
C        NCHAR  - number of characters in uffer 
C        ICH    - character counter 
      integer*2 ibuf(20)
C               - class buffer
      integer*2 lfr(3)
      integer*2 lfreqvt(3,15)
C               - frequency holder
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ia(2) 
C               - attenuator settings 
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC calls 
      dimension lhex(15)
C               - hex characters corresponding to 1 - 14. 
C 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 4.  CONSTANTS USED
C 
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ilen/40/ 
      data lhex   /2hv1,2hv2,2hv3,2hv4,2hv5,2hv6,2hv7,2hv8,2hv9,2hva, 
     /             2hvb,2hvc,2hvd,2hve,2hvf/
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:  800213
C 
C     PROGRAM STRUCTURE 
C 
C     1. If class buffer contains command name with "=" then we have
C     parameters to set the VC.  If only the command name is present, 
C     then read the VC. 
      nrec = 0
C 
      iclcm = ip(1) 
      ierr = 0
      ichold = -99
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C                   If no parameters, go read VC
      call fs_get_lfreqv(lfreqv)
      if (cjchar(ibuf,ieq+1).eq.'?') then
        ip(4) = o'77'
C       IP(5) = ICLCM
        call vcdis(ip,ivcn,iclcm)
        return
      endif
C 
      if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600 
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700 
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C                   VCnn=<freq>,<bw>,<TPI>,<atnU>,<atnL>,<MATmode>
C     The frequency has no default.  Bandwidth defaults to 2 MHz. 
C     TPI defaults to U, and attenuators to 10 db.
C 
      ich = 1+ieq 
      call gtprm(ibuf,ich,nchar,2,freq,ierr) 
C                   Pick up frequency, real number
      if (cjchar(freq,1).eq.'*') then
        idumm1 = ichmv(lfr,1,lfreqv(1,ivcn),1,6)
      else if (cjchar(freq,1).eq.',') then     !   error if default specified
        ierr = -101
        goto 990
      else if (freq.gt.500.0.or.freq.le.0.0) then
        ierr = -201
        goto 990
      else
        ifr = ifix(freq)
        idumm1 = ib2as(ifr,lfr,1,o'41400'+3)
        idumm1 = ichmv(lfr,4,2h. ,1,1)
        idumm1 = ib2as(ifix((freq-ifr+.001)*100.0),lfr,5,o'41000'+2)
      endif
C 
      ic1=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
C                   Get the bandwidth as characters 
      if (cjchar(parm,1).eq.'*') then
        ibw = ibwvc(ivcn)
      else if (cjchar(parm,1).eq.',') then
        ibw = 5       !  default is 2 mhz
      else
        call ivced(1,ibw,ibuf,ic1,ich-2)
        if (ibw.lt.0) then
          ierr = -202
          goto 990
        endif
      endif
C 
      ic1 = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
C                   Get the TPI code, ASCII 
      if (cjchar(parm,1).eq.'*') then
        itp = itpivc(ivcn)
      else if (cjchar(parm,1).eq.',') then
        itp = 2           !  the default is usb
      else
        call ivced(2,itp,parm,1,2)
        if (itp.lt.0) then
          ierr = -203
          goto 990
        endif
      endif
C 
      do i=1,2
        call gtprm(ibuf,ich,nchar,1,parm,ierr) 
C                   Get the attenuator setting
        ia(i) = iparm(1)
        if (cjchar(parm,1).eq.'*'.and.i.eq.1) ia(i)=iatuvc(ivcn) 
        if (cjchar(parm,1).eq.'*'.and.i.eq.2) ia(i)=iatlvc(ivcn) 
        if (cjchar(parm,1).eq.',') ia(i)=10
        if (ia(i).ne.0.and.ia(i).ne.10) then
          ierr = -203-i
          goto 990
        endif
      enddo
C 
C 
C     3. Finally, format the buffer for the controller. 
C     The buffer is set up as follows:
C                   mmVndddddddd
C     where 
C                   mm = MAT mode, binary integer 
C                   Vn = which VC, n=1 to E (hex 14)
C                   dddddddd = data for VC
C 
      ibuf(1) = 0
      ibuf(2) = lhex(ivcn)
      call vc2ma(ibuf(3),lfr,ibw,itp,ia(1),ia(2)) 
C                   Format the data part of the buffer
C 
C 
C     4. Now plant these values into COMMON.
C     Next send the buffer to SAM.
C     Finally schedule BOSS to request that MATCON gets the data. 
C 
      call fs_get_icheck(icheck(ivcn),ivcn)
      ichold = icheck(ivcn) 
      icheck(ivcn) = 0
      call fs_set_icheck(icheck(ivcn),ivcn)
      idumm1 = ichmv(lfreqv(1,ivcn),1,lfr,1,6)
      call fs_set_lfreqv(lfreqv)
C     FREQVC(IVCN) = DAS2B(LFREQV(1,IVCN),1,6,IERR) 
      freqvc(ivcn) = freq - amod(freq+.001,.01) 
      ibwvc(ivcn) = ibw 
      itpivc(ivcn) = itp
      iatuvc(ivcn) = ia(1)
      iatlvc(ivcn) = ia(2)
C 
      iclass=0
      call put_buf(iclass,ibuf,-12,2hfs,0)
      nrec = 1
      goto 800
C 
C 
C     5.  This is the read device section.
C     Fill up two class buffers, one requesting ! data (mode -1), 
C     the other % (mode -2).
C 
500   ibuf(2) = lhex(ivcn)
      iclass = 0
      do i=1,2
        ibuf(1) = -i
        call put_buf(iclass,ibuf,-4,2hfs,0)
      enddo
      nrec = 2
      goto 800
C 
C 
C     6. This is the test/reset device section. 
C 
600   ibuf(1) = 6 
      ibuf(2) = lhex(ivcn)
      iclass=0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C
C
C     7. This is the alarm query and reset request.
C
700   ibuf(1) = 7
      ibuf(2) = lhex(ivcn)
      iclass=0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C
C
C     8. All MATCN requests are scheduled here, and then VCDIS called.
C
800   call run_matcn(iclass,nrec)
      call rmpar(ip)
      if (ichold.ne.-99) then
        icheck(ivcn) = ichold
        call fs_set_icheck(icheck(ivcn),ivcn)
      endif
      if (ichold.ge.0) then
        icheck(ivcn) = mod(ichold,1000)+1
        call fs_set_icheck(icheck(ivcn),ivcn)
      endif
      call vcdis(ip,ivcn,iclcm)
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qv',ip(4),1,2)
      return
      end
