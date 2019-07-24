      subroutine repro(ip)
C  set up reproduce tracks
C
C   REPRO controls the reproduce tracks in the tape controller
C
C     PROGRAMMER: NRV
C     LAST MODIFIED:  800829
C  WHO  WHEN    DESCRIPTION
C  GAG  910128  Added Reproduce Electronics logic to change tracks according
C               to RPRO_FS variable.
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
C     COMMON BLOCKS
C
      include '../include/fscom.i'
C
C     SUBROUTINE INTERFACE:
C
C     CALLED SUBROUTINES: GTPRM
C 
C     LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        IMMODE - mode for MAT
C        ICH    - character counter 
      integer*2 ibuf(20)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls 
C        ITA,ITB,IBW,IEQ,IBY
C               - variables for tracks, bandwidths, bypass
      dimension bws(7)
C               - lists for comparisons
      character cjchar
C
      equivalence (reg,ireg(1)),(parm,iparm(1))
C
C     INITIALIZED
      data ilen/40/
      data bws/0.0625,0.125,0.25,0.5,1.0,2.0,4.0/
C
C
C  1. If we have parameters, then we are to set the TP.
C     If no parameters, we have been requested to read the TP.
C
      ichold = -99
      iclcm = ip(1)
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ilen,ireg(2))
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500
C                   If no parameters, go read device
      if (ieq.eq.nchar.or.cjchar(ibuf,ieq+1).ne.'?') goto 140
      ip(1) = 0
      ip(4) = o'77'
      call repds(ip,iclcm)
      return
C
140   if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700
C
C  2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters:
C            REPRO=<bypass>,<trackA>,<trackB>,<bw>,<eq>
C     Choices are <trackA> and <trackB>: 1 to 28, defaults 1 and 2.
C                 <bw>, <eq>: 4,2,1,0.5,0.25,0.125,0.0625.  Default 2MHz
C                             for <bw>, default for <eq>=<bw>.
C                 <bypass>: BYPASS or ReadAfterWrite.  Default BYP.
C
C  2.1 BYPASS, PARAMETER 1
C
      ich = 1+ieq
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(iparm,1).ne.','.and.cjchar(iparm,1).ne.'*') goto 211
      if (cjchar(iparm,1).eq.'*') iby = ibypas
      if (cjchar(iparm,1).eq.',') iby = 1
C                   Default to bypass.
      goto 220
211   iby = -1
      if (ichcm_ch(parm,1,'byp').eq.0) iby = 1
      if (ichcm_ch(parm,1,'raw').eq.0) iby = 0
      if (iby.ne.-1) goto 220
      ierr = -201
      goto 990
C
C  2.2 TRACK A, PARAMETER 2
C
220   call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 221
      if (cjchar(parm,1).eq.'*') ita = itrakaus_fs
      if (cjchar(parm,1).eq.',') ita = 1
C                   Default track is 1 for A
      goto 230
221   ita = iparm(1)
      if (ita.ge.0.and.ita.le.28) goto 230
      ierr = -202
      goto 990
C
C
C  2.3 TRACK B, PARAMETER 3
C
230   call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 231
      if (cjchar(parm,1).eq.'*') itb = itrakbus_fs
      if (cjchar(parm,1).eq.',') itb = 1
C                   Default for track B is 1
      goto 240
231   itb = iparm(1)
      if (itb.ge.0.and.itb.le.28) goto 240
      ierr = -203
      goto 990
C
C  CHECK FOR ODD AND EVEN TRACKS GIVEN FOR ODD OR EVEN ELECTRONICS
C
240   continue
      if (
     .    ( (mod(ita,2).eq.0.and.mod(itb,2).ne.0).or.
     .      (mod(ita,2).ne.0.and.mod(itb,2).eq.0)    ).and.
     .    (ita.ne.0.and.itb.ne.0)  .and.iby.ne.1.and.
     .    (rpro_fs.eq.2.or.rpro_fs.eq.1)
     .    ) then
        ierr = -206
        goto 990
      end if
C
C  2.4 BANDWIDTH, PARAMETER 4
C
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if (cjchar(parm,1).ne.','.and.cjchar(parm,1).ne.'*') goto 242
      if (cjchar(parm,1).eq.'*') ibw = ibwtap
      if (cjchar(parm,1).eq.',') ibw = 6
C                   Use 2 MHz bandwidth as default
      goto 250
242   do 245 i=1,7
        if (parm.eq.bws(i)) goto 246
245     continue
      ierr = -204
      goto 990
246   ibw = i
C
C
C  2.5 EQUALIZER, PARAMETER 5
C
250   call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if (cjchar(iparm,1).ne.','.and.cjchar(iparm,1).ne.'*') goto 251
      if (cjchar(iparm,1).eq.'*') ieq = ieqtap
      if (cjchar(iparm,1).eq.',') ieq = ibw - 1
C                   Default is for BW=EQ
      goto 300
251   do 255 i=1,7
        if (parm.eq.bws(i)) goto 256
255     continue
      ierr = -205
      goto 990
256   ieq = i-1
C
C
C
C  3. Now plant these values into COMMON.
C
      call fs_get_icheck(icheck(18),18)
300   ichold = icheck(18)
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      itrakaus_fs=ita
      if (ita.ne.0.and.iby.ne.1) then
        if (rpro_fs.eq.2) then         !even
          if (mod(ita,2).ne.0) ita = ita + 1
        else if (rpro_fs.eq.1) then    !odd
          if (mod(ita,2).eq.0) ita = ita - 1
        else if (rpro_fs.ne.0) then    !all
          ierr = -207
          goto 990
        end if
      end if
      itraka = ita
      call fs_set_itraka(itraka)
C
      itrakbus_fs=itb
      if (itb.ne.0.and.iby.ne.1) then
        if (rpro_fs.eq.2) then         !even
          if (mod(itb,2).ne.0) itb = itb + 1
        else if (rpro_fs.eq.1) then    !odd
          if (mod(itb,2).eq.0) itb = itb - 1
        else if (rpro_fs.ne.0) then    !all
          ierr = -207
          goto 990
        end if
      end if
      itrakb = itb
      call fs_set_itrakb(itrakb)
C
      ibwtap = ibw
      ieqtap = ieq
      ibypas = iby
C
C  4. Set up buffer for tape drive.  Send to MATCN.
C                   TP(rdebtbta
C
      ibuf(1) = 0
      call char2hol('tp',ibuf(2),1,2)
      call rp2ma(ibuf(3),iby,ieq,ibw,ita,itb)
C
      iclass = 0
      call put_buf(iclass,ibuf,-13,2hfs,0)
C
      nrec = 1
      goto 800
C
C
C  5. This is the read device section.
C     Fill up three class buffers, one requesting ( data (mode -3),
C     one  ) (mode -4), one ! (mode -1).
C
500   call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      ibuf(1) = -1
      call put_buf(iclass,ibuf,-4,2hfs,0)
C
      nrec = 1
      goto 800
C
C
C  6. This is the test/reset device section.
C
600   ibuf(1) = 6
      call char2hol('tp',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C
C
C  7. This is the alarm query and reset request.
C
700   ibuf(1) = 7
      call char2hol('tp',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C
C
C  8. All MATCN requests are scheduled here, and then RPDIS called.
C
800   call run_matcn(iclass,nrec)
      call rmpar(ip)
      if(ichold.ne.-99) then
        icheck(18) = ichold
        call fs_set_icheck(icheck(18),18)
      endif
      if (ichold.ge.0) then
         icheck(18) = mod(ichold,1000)+1
         call fs_set_icheck(icheck(18),18)
         krptp_fs=.true.
      endif
      call repds(ip,iclcm)
      return
C
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qr',ip(4),1,2)
      return
      end
