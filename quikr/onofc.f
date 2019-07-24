      subroutine onofc(ip)
C
C  onoff setup control
C 
C     ONOFC sets up the common variables necessary for
C      the proper execution of program ONOFF
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C   COMMON BLOCKS USED
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
C     CALLED SUBROUTINES: NFDIS, utilities
C 
C   LOCAL VARIABLES 
C 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(40)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      integer*2 iprm(20)
C               - parameter returned from FDFLD
      integer*2 dtnam
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC calls 
      integer source
      logical rn_test
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 
C  INITIALIZED VARIABLES
C 
      data ilen/80/ 
C 
C  PROGRAMMER: MWH  CREATED: 840510 
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920714  Made Mark IV a valid rack to go along with Mark III
C 
C 
C     1. If we have a class buffer, then we are to set the
C     variables in common for ONOFF to use. 
C 
      call ifill_ch(ibuf,1,ilen,' ') 
      iclcm = ip(1) 
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = min0(ilen,ireg(2))
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 490
C                   If no parameters, schedule ONOFF
      if(nchar.eq.ieq) goto 220 
      if (cjchar(ibuf,ieq+1).ne.'?') goto 220
      ip(1) = 0 
      ip(4) = o'77' 
      call nfdis(ip,ibuf,ilen,nchar)
      return
C
C     2. Step through buffer getting each parameter and decoding it.
C     2.1 FIRST parm, number of repetitions
C
220   continue
      ich=1+ieq
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).eq.',') nrep = 2
C                 Default is 1 repetition
      if (cjchar(parm,1).eq.'*') nrep = nrepnf
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') nrep=iparm(1)
      if (nrep.ge.1.and.nrep.le.10) goto 250
        ierr = -401
        goto 990
C
C  2.2  SECOND parm, integration period
C
250   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if(cjchar(parm,1).eq.',') intp = 1
      if(cjchar(parm,1).eq.'*') intp = intpnf
      if(cjchar(parm,1).ne.','.and.cjchar(parm,1).ne.'*') 
     .  intp = iparm(1)
      if(intp.ge.1.and.intp.le.10) goto 260
        ierr = -402
        goto 990
C
C     2.3 Third parm, detector device 1.
C
260   continue
      call fdfld(ibuf,ich,nchar,ic1,ic2)
      if (ic1.eq.0) then
        ierr = -403
        goto 990 
      endif
      inumb=ic2-ic1+1
      call ifill_ch(iprm,1,40,' ')
      idum = ichmv(iprm,1,ibuf,ic1,inumb)
      ich=ic2+2 !! point beyond next comma

      if (cjchar(iprm,1).ne.'*'.and.cjchar(iprm,1).ne.',')
     .  ldv1=dtnam(iprm,1,inumb)
      if (cjchar(iprm,1).eq.'*') then
        idumm1 = ichmv(ldv1,1,ldv1nf,1,2)
        goto 360
      endif

      call fs_get_rack(rack)

      if((MK3.eq.iand(rack,MK3)).or.(MK4.eq.iand(rack,MK4))) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv(ldv1,1,2Hi1,1,2)
C                      Default is IF1
        if(cjchar(ldv1,1).eq.'i'.or.cjchar(ldv1,1).eq.'v') goto 360
      else if (VLBA .eq. iand(rack,VLBA)) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv(ldv1,1,2Hia,1,2)
C                      Default is IA
        if ((cjchar(ldv1,1).eq.'i').or.
     .      ((cjchar(ldv1,1).ge.'1').and.(cjchar(ldv1,1).le.'9')).or.
     .      ((cjchar(ldv1,1).ge.'a').and.(cjchar(ldv1,1).le.'f')))
     .    goto 360
      endif
C
      ierr = -403
      goto 990
C           Illegal value entered
C
C     2.5 Fourth parm, detector device 2.
C
360   continue
      call fdfld(ibuf,ich,nchar,ic1,ic2)
      if (ic1.eq.0) then
        ierr = -406
        goto 990 
      endif
      inumb=ic2-ic1+1
      call ifill_ch(iprm,1,40,' ')
      idum = ichmv(iprm,1,ibuf,ic1,inumb)
      ich=ic2+2 !! point beyond next comma

      if (cjchar(iprm,1).ne.'*'.and.cjchar(iprm,1).ne.',')
     .  ldv2=dtnam(iprm,1,inumb)
      if (cjchar(iprm,1).eq.'*') then
        idumm1 = ichmv(ldv2,1,ldv2nf,1,2)
        goto 400
      endif

      call fs_get_rack(rack)

      if((MK3.eq.iand(rack,MK3)).or.(MK4.eq.iand(rack,MK4))) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv(ldv2,1,2Hi2,1,2)
C                      Default is IF2
        if(cjchar(ldv2,1).eq.'i'.or.cjchar(ldv2,1).eq.'v') goto 400
      else if (VLBA .eq. iand(rack,VLBA)) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv(ldv2,1,2Hib,1,2)
C                      Default is IB
        if ((cjchar(ldv2,1).eq.'i').or.
     .      ((cjchar(ldv2,1).ge.'1').and.(cjchar(ldv2,1).le.'9')).or.
     .      ((cjchar(ldv2,1).ge.'a').and.(cjchar(ldv2,1).le.'f')))
     .    goto 400
      endif
C
      ierr = -406
      goto 990
C           Illegal value entered
C
C  2.7  Fifth parm, cut off elevation
C
400   continue
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(cjchar(parm,1).eq.',') ctof= 60.*RPI/180.
      if(cjchar(parm,1).eq.'*') ctof = ctofnf
      if(cjchar(parm,1).ne.','.and.cjchar(parm,1).ne.'*')
     +           ctof = parm*RPI/180.
      if(ctof.ge.0.and.ctof.le.90.1*RPI/180.) goto 450
        ierr = -409
        goto 990
C 
C  2.8  Sixth parm, step size 
C 
450   continue
      call gtprm(ibuf,ich,nchar,2,parm,ierr) 
      if(cjchar(parm,1).eq.',') step= 5. 
      if(cjchar(parm,1).eq.'*') step = stepnf
      if(cjchar(parm,1).ne.','.and.cjchar(parm,1).ne.'*')
     +           step = parm
      if(step.gt.0.and.step.le.99) goto 470
        ierr = -410
        goto 990
C
C  3.0  Set common variables to their new values
C
470   continue
      idumm1 = ichmv(ldv1nf,1,ldv1,1,4)
      idumm1 = ichmv(ldv2nf,1,ldv2,1,4)
      nrepnf = nrep
      intpnf = intp
      ctofnf = ctof
      stepnf = step
      goto 990
C
C  5.0  Schedule ONOFF to start working
C
C  Determine cal temp and frequency for device 1.
C
490   continue
      if((rack.and.iand(MK3,rack)).or.(rack.and.iand(MK4,rack))) then
        if(cjchar(ldv1nf,1).eq.'i'.or.cjchar(ldv1nf,1).eq.'v') 
     .    goto 500
          ierr = -503
          goto 990
C
500     continue
        if(cjchar(ldv1nf,1).ne.'i') goto 505
        if(ichcm_ch(ldv1nf,1,'i1').ne.0) goto 502
          cal1 = caltmp(1)
          bm1=beamsz_fs(1)
          fx1=flx1fx_fs
          goto 510
502     continue
        cal1 = caltmp(2)
        bm1=beamsz_fs(2)
        fx1=flx2fx_fs
        goto 510
505     continue
        indvc = ia2hx(ldv1nf,2)
        if(iabs(ifp2vc(indvc)).ne.1) goto 507
        cal1 = caltmp(1)
        bm1=beamsz_fs(1)
        fx1=flx1fx_fs
        goto 510
507     continue
        if(iabs(ifp2vc(indvc)).ne.2) goto 508
        cal1 = caltmp(2)
        bm1=beamsz_fs(2)
        fx1=flx2fx_fs
        goto 510
508     continue
        ierr=-411
        goto 990
      else
        indbc=ia2hx(ldv1nf,1)
        if(ichcm_ch(ldv1nf,1,'ia').eq.0) then
          ichain=1
        else if(ichcm_ch(ldv1nf,1,'ib').eq.0) then
          ichain=2
        else if(indbc.ge.1.and.indbx.le.14) then
          call fs_get_bbc_source(source,indbc)
          write(6,'(/'' source indbc'',2i10/)') source,indbc
          if(source.eq.0) then
            ichain=1
          else if(source.eq.1) then
            ichain=2
          else
            ierr=-413
            goto 990
          endif
        else
          ierr=-414
          goto 990
        endif
      endif
      write(6,'(/'' ichain '',i10/)') ichan 
      if(ichain.eq.1) then
        cal1 = caltmp(1)
        bm1=beamsz_fs(1)
        fx1=flx1fx_fs
      else
        cal1 = caltmp(2)
        bm1=beamsz_fs(2)
        fx1=flx2fx_fs
      endif
C
C  Now check the cal and freq values.
C
510   continue
      if(cal1.ne.0) goto 515
        ierr = -404
        goto 990
515   if(bm1.gt.4.8e-8) goto 520
        ierr = -405
        goto 990
C
C   Determine cal temp and frequency for device 2.
C
520   continue
      if((rack.eq.iand(MK3,rack)).or.(rack.eq.iand(MK4,rack))) then
        if(cjchar(ldv2nf,1).ne.'i') goto 525
        if(ichcm_ch(ldv2nf,1,'i1').ne.0) goto 522
          cal2 = caltmp(1)
          bm2= beamsz_fs(1)
          fx2=flx1fx_fs
          goto 530
522     continue
        cal2 = caltmp(2)
        bm2=beamsz_fs(2)
        fx2=flx2fx_fs
        goto 530
525     continue
        indvc = ia2hx(ldv2nf,2)
        if(iabs(ifp2vc(indvc)).ne.1) goto 527
          cal2 = caltmp(1)
          bm2  = beamsz_fs(1)
          fx2=flx1fx_fs
          goto 530
527     continue
        if(iabs(ifp2vc(indvc)).ne.2) goto 528
        cal2 = caltmp(2)
        bm2  = beamsz_fs(2)
        fx2=flx2fx_fs
        goto 530
528     continue
        ierr=-412
        goto 990
      else
        indbc=ia2hx(ldv2nf,1)
        if(ichcm_ch(ldv2nf,1,'ia').eq.0) then
          ichain=1
        else if(ichcm_ch(ldv2nf,1,'ib').eq.0) then
          ichain=2
        else if(indbc.ge.1.and.indbx.le.14) then
          call fs_get_bbc_source(source,indbc)
          write(6,'(/'' source indbc'',2i10/)') source,indbc
          if(source.eq.0) then
            ichain=1
          else if(source.eq.1) then
            ichain=2
          else
            ierr=-413
            goto 990
          endif
        else
          ierr=-414
          goto 990
        endif
      endif
      write(6,'(/'' ichain '',i10/)') ichan 
      if(ichain.eq.1) then
        cal2 = caltmp(1)
        bm2=beamsz_fs(1)
        fx2=flx1fx_fs
      else
        cal2 = caltmp(2)
        bm2=beamsz_fs(2)
        fx2=flx2fx_fs
      endif
C
C  Now check the cal and freq values.
C
530   continue
      if(cal2.ne.0) goto 535
        ierr = -407
        goto 990
535   if(bm2.gt.4.8e-8) goto 600
        ierr = -408
        goto 990
C
600   continue
      cal1nf=cal1
      cal2nf=cal2
      bm1nf_fs=bm1
      bm2nf_fs=bm2
      fx1nf_fs=fx1
      fx2nf_fs=fx2
      if((rack.eq.iand(MK3,rack)).or.(rack.eq.iand(MK4,rack))) then
        if(cjchar(ldv1nf,1).eq.'i') goto 602
        indvc = ia2hx(ldv1nf,2)
        if(freqvc(indvc).gt.96.0.and.freqvc(indvc).lt.504.00) goto 602
C             - VC MUST BE SETUP
          ierr = -504
          goto 990
602     continue
        if(cjchar(ldv2nf,1).eq.'i') goto 604
        indvc = ia2hx(ldv2nf,2)
        if(freqvc(indvc).gt.96.0.and.freqvc(indvc).lt.504.00) goto 604
C             - VC MUST BE SETUP
          ierr = -505
          goto 990
      endif
C
C          If it's not dormant, then error.
C
604   continue
      if(.not.rn_test('onoff')) goto 610
      ierr = -501
      goto 990
605   ierr = -502
      goto 990
610   continue
      call write_quikr
      call run_prog('onoff','nowait',ip(1),ip(2),ip(3),ip(4),ip(5))
C      Schedule ONOFF
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qz',ip(4),1,2)

      return
      end 
