      subroutine fvpnt(ip)
C 
C     FVPNT sets up the common variables necessary for
C      the proper execution of program FIVPT
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
C   COMMON BLOCKS USED
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: FVDIS, utilities
C 
C   LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(40)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      integer*2 iprm(20)
C               - parameter returned from FDFLD
      integer*2 dtnam
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls
      integer*2 legax(8)
      logical rn_test
      dimension lax(2)
      character cjchar
      integer source
      equivalence (reg,ireg(1)),(parm,iparm(1))
C
C  INITIALIZED VARIABLES
C
      data ilen/80/
      data legax/2hha,2hdc,2haz,2hel,2hxy,2hew,2hxy,2hns/
C
C  PROGRAMMER: MWH  CREATED: 840510
C  HISTORY:
C  WHO  WHEN    WHAT 
C  gag  920714  Added Mark IV rack to be valid along with Mark III.
C
C     1. If we have a class buffer, then we are to set the
C     variables in common for FIVPT to use.
C
      call ifill_ch(ibuf,1,ilen,' ') 
      iclcm = ip(1) 
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = min0(ilen,ireg(2))
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 390
C                   If no parameters, schedule FIVPT
      if(nchar.eq.ieq) goto 210 
      if (cjchar(ibuf,ieq+1).ne.'?') goto 210
      ip(1) = 0 
      ip(4) = o'77' 
      call fpdis(ip,ibuf,ilen,nchar)
      return
C
C
C     2. Step through buffer getting each parameter and decoding it.
C     2.1 First parm, axis type
C
210   continue
      ich = 1+ieq
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') idumm1 = ichmv_ch(lax,1,'hadc')
C                 The default is HADC
      if (cjchar(parm,1).eq.'*') idumm1 = ichmv(lax,1,laxfp,1,4)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',')
     .  idumm1 = ichmv(lax,1,parm,1,4)
C
      do 215 i=1,13,4
        if(ichcm(lax,1,legax,i,4).eq.0) goto 220
215   continue
      ierr = -201
      goto 990
C 
C     2.2 Second parm, number of repetitions
C 
220   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).eq.',') nrep = 1
C                 Default is 1 repetition 
      if (cjchar(parm,1).eq.'*') nrep = nrepfp 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') 
     .  nrep = iparm(1) 
      if (nrep.ge.-10.and.nrep.le.10.and.nrep.ne.0) goto 230
        ierr = -204 
        goto 990
C 
C     2.3 Third parm, number of points
C 
230   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).eq.',') npts = 3
C                 Default is 3 points
      if (cjchar(parm,1).eq.'*') npts = nptsfp
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',')npts=iparm(1)
      if(npts.lt.0) then
         npts = 2*(-npts/2)+1
         npts = -npts
      else
         npts = 2*(npts/2)+1
      endif
      if (abs(npts).ge.3.and.abs(npts).le.31) goto 240
        ierr = -205
        goto 990
C
C  2.4  Fourth parm, step size
C
240   continue
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(cjchar(parm,1).ne.',') goto 242
        step = 0.5
        goto 250
242   if(cjchar(parm,1).ne.'*') goto 245
        step = stepfp
        goto 250
245   if(ierr.eq.0) goto 247
        ierr = -208 
        goto 990
247   step = parm 
      ierr = 0
C 
C  2.5  Fifth parm, integration period
C 
250   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if(cjchar(parm,1).eq.',') intp = 1 
      if(cjchar(parm,1).eq.'*') intp = intpfp
      if(cjchar(parm,1).ne.','.and.cjchar(parm,1).ne.'*')
     .   intp = iparm(1)
      if(intp.ge.1.and.intp.le.32) goto 260 
        ierr = -207 
        goto 990
C 
C     2.6 Sixth parm, detector device.  
C 
260   continue
      call fdfld(ibuf,ich,nchar,ic1,ic2)
      if (ic1.eq.0) then
        ierr = -202
        goto 990 
      endif
      inumb=ic2-ic1+1
      call ifill_ch(iprm,1,40,' ')
      idum = ichmv(iprm,1,ibuf,ic1,inumb)

      if (cjchar(iprm,1).ne.'*'.and.cjchar(iprm,1).ne.',')
     .  ldev=dtnam(iprm,1,inumb)
      if (cjchar(iprm,1).eq.'*') then
        idumm1 = ichmv(ldev,1,ldevfp,1,2)
        goto 300
      endif
      if(cjchar(iprm,1).eq.'u'.and.index('56',cjchar(iprm,2)).ne.0) then
        idumm1 = ichmv(ldev,1,iprm,1,2)
        goto 300
      endif
C
      call fs_get_rack(rack)
      if (MK3.eq.rack.or.MK4.eq.rack) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'i1')
C                      Default for MK3 and MK4 is IF1
        if(cjchar(ldev,1).eq.'i'.or.cjchar(ldev,1).eq.'v') goto 300

      else if (VLBA .eq. rack.or.VLBA4.eq.rack) then
        if (cjchar(iprm,1).eq.',') idumm1 = ichmv_ch(ldev,1,'ia')
C                      Default for VLBA is IA
        if ((cjchar(ldev,1).eq.'i').or.
     .      ((cjchar(ldev,1).ge.'1').and.(cjchar(ldev,1).le.'9')).or.
     .      ((cjchar(ldev,1).ge.'a').and.(cjchar(ldev,1).le.'f')))
     .    goto 300
      endif
C
      ierr = -202
      goto 990
C           Illegal value entered
C
C  3.0  Set common variables to their new values
C
300   continue
      idumm1 = ichmv(laxfp,1,lax,1,4)
      idumm1 = ichmv(ldevfp,1,ldev,1,2)
      nrepfp = nrep
      nptsfp = npts
      intpfp = intp
      stepfp = step
      goto 990
C
C  4.0  Schedule FIVPT to start working
C
390   continue
      do 395 i=1,13,4
        if(ichcm(laxfp,1,legax,i,4).eq.0) goto 400
395   continue
      ierr = -304
      goto 990
C
400   continue
      if(cjchar(ldevfp,1).eq.'u') then
         if(cjchar(ldevfp,2).eq.'5') then
            ichain=5
         else
            ichain=6
         endif
         goto 410
      endif
      if(MK3.eq.rack.or.MK4.eq.rack) then
        if(cjchar(ldevfp,1).ne.'i') goto 405
        if(ichcm_ch(ldevfp,1,'i1').ne.0) goto 402
          ichain=1
          goto 410
402     continue
        if(ichcm_ch(ldevfp,1,'i2').ne.0) goto 403
          ichain=2
          goto 410
403     continue
          ichain=3
          goto 410
c
c  video channels
c
405     continue
        indvc = ia2hx(ldevfp,2)
        call fs_get_ifp2vc(ifp2vc)
        ichain=iabs(ifp2vc(indvc))
        if(ichain.lt.1.or.ichain.gt.3) then
          ierr=-209
          goto 990
        endif
      else    !VLBA
        indbc=ia2hx(ldevfp,1)
        if(ichcm_ch(ldevfp,1,'ia').eq.0) then
          ichain=1
        else if(ichcm_ch(ldevfp,1,'ib').eq.0) then
          ichain=2
        else if(ichcm_ch(ldevfp,1,'ic').eq.0) then
          ichain=3
        else if(ichcm_ch(ldevfp,1,'id').eq.0) then
          ichain=4
        else if(indbc.ge.1.and.indbx.le.14) then
          call fs_get_bbc_source(source,indbc)
          ichain=source+1
          if(ichain.lt.1.or.ichain.gt.4) then
            ierr=-210
            goto 990
          endif
        else
          ierr=-211
          goto 990
        endif
      endif
C
C  Now check the cal and freq values.
410   continue
      if(ichain.eq.1) then
        cal = caltmp(1)
        bm=beamsz_fs(1)
        fx=flx1fx_fs
      else if(ichain.eq.2) then
        cal = caltmp(2)
        bm=beamsz_fs(2)
        fx=flx2fx_fs
      else if(ichain.eq.3) then
        cal = caltmp(3)
        bm=beamsz_fs(3)
        fx=flx3fx_fs
      else if(ichain.eq.4) then
        cal = caltmp(4)
        bm=beamsz_fs(4)
        fx=flx4fx_fs
      else if(ichain.eq.5) then
        cal = caltmp(5)
        bm=beamsz_fs(5)
        fx=flx5fx_fs
      else if(ichain.eq.6) then
        cal = caltmp(6)
        bm=beamsz_fs(6)
        fx=flx6fx_fs
      endif
      if(cal.ne.0.0) goto 415
        ierr = -203
        goto 990
415   if(bm.gt.4.8d-8) goto 420
        ierr = -206
        goto 990
420   continue
      calfp = cal
      bmfp_fs= bm
      fxfp_fs = fx
      ichfp_fs = ichain

      if(rack.eq.MK3.or.rack.eq.MK4) then
        if(cjchar(ldevfp,1).ne.'v') goto 504
        indvc = ia2hx(ldevfp,2)
        call fs_get_freqvc(freqvc)
        if(freqvc(indvc).gt.96.0.and.freqvc(indvc).lt.504.00) goto 504
C             - VC MUST BE SETUP
          ierr = -303
          goto 990
      endif
C          If it's not dormant, then error.
C
504   if(.not.rn_test('fivpt')) goto 510
      ierr = -301
      goto 990
505   ierr = -302
      goto 990
510   continue
      call write_quikr
      call run_prog('fivpt','nowait',ip(1),ip(2),ip(3),ip(4),ip(5))
      ierr=0
C      Schedule FIVPT
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qz',ip(4),1,2)
      return
      end
