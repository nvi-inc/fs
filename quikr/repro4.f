      subroutine repro4(ip)
C  set up reproduce for Mark IV
C
C   REPRO controls the reproduce tracks in the tape controller
C
C  WHO  WHEN    DESCRIPTION
C  gag  920727  Created: copied from repro.f
C
C     INPUT VARIABLES:
C
      dimension ip(5)
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
C        ITA,ITB,IEQ,IBY,IBR
C               - variables for tracks, equalizer, bypass, bitrate
      dimension ibws1(4), ibws2(4), ibws3(4)
C               - lists for comparisons
      character cjchar
C
      equivalence (parm,iparm(1))
C
C     INITIALIZED
      data ilen/40/
      data ibws1/0,1,2,3/
      data ibws2/80,135,160,270/
      data ibws3/16,8,4,2/
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
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ilen,ireg(2))
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500
C                   If no parameters, go read device
      if (ieq.eq.nchar.or.cjchar(ibuf,ieq+1).ne.'?') goto 140
      ip(1) = 0
      ip(4) = o'77'
      call repds4(ip,iclcm)
      return
C
140   if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700
C
C  2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters:
C            REPRO=<mode>,<trackA>,<trackB>,<equalizer>,<bitrate>
C     Choices are <mode>: BYPASS or ReadAfterWrite (RAW) or Read. 
C                         Default BYP.
C  <trackA> and <trackB>: 0 to 35, defaults 2 and 3. For tracks on 
C                         head stack 1, add 100 to desired track number.
C                         If mode is read, only tracks from stack 0 may 
C                         be specified.
C            <equalizer>: 0, 1, 2 (default if read), 3 or dis (default if
C                         bypass. 80, 135, 160, or 270 to select playback
C                         rate.
C              <bitrate>: 16, 8, 4, 2. default is one that corresponds to
C                         equalizer.  4 -> 80
C                                     8 -> 160, 270
C
C  2.1 MODE, PARAMETER 1
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
      if ((ichcm_ch(parm,1,'raw').eq.0).or.
     .    (ichcm_ch(parm,1,'read').eq.0)) iby = 0
      if (iby.ne.-1) goto 220
      ierr = -201
      goto 990
C
C  2.2 TRACK A, PARAMETER 2
C
220   call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 221
      if (cjchar(parm,1).eq.'*') ita = itrakaus_fs
      if (cjchar(parm,1).eq.',') ita = 2
C                   Default track is 1 for A
      goto 230
221   ita = iparm(1)
      if ((ita.ge.0.and.ita.le.35).or.
     .    (ita.ge.100.and.ita.le.135)) goto 230
      ierr = -202
      goto 990
C
230   if ((ita.ge.100).and.(iby.eq.0)) then
        ierr = -208
        goto 990
      endif
C
C
C  2.3 TRACK B, PARAMETER 3
C
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 231
      if (cjchar(parm,1).eq.'*') itb = itrakbus_fs
      if (cjchar(parm,1).eq.',') itb = 3
C                   Default for track B is 3
      goto 240
231   itb = iparm(1)
      if ((itb.ge.0.and.itb.le.35).or.
     .    (itb.ge.100.and.itb.le.135)) goto 240
      ierr = -203
      goto 990
C
240   if ((itb.ge.100).and.(iby.eq.0)) then
        ierr = -208
        goto 990
      endif
C
C  2.4 EQUALIZER, PARAMETER 4
C
      ichs =ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (ichcm_ch(parm,1,'test').eq.0) then
        ieq = 1
        goto 250
      endif
      if (ichcm_ch(parm,1,'dis').eq.0) then
        ieq = 4
        goto 250
      endif
      ich = ichs
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if (cjchar(parm,1).ne.','.and.cjchar(parm,1).ne.'*') goto 242
      if (cjchar(parm,1).eq.'*') ieq = ieq4tap
C  DEFAULT EQUALIZER IS 2 IF MODE IS READ OR DISABLE.
      if (cjchar(parm,1).eq.',') then
        if (iby.eq.1) then
          ieq = 4
        else
          ieq = 2
        endif
      endif
C
      goto 250
242   continue
      do i=1,4   !! selects one of 0,1,2,3
        if (parm.eq.ibws1(i)) goto 246
      enddo
      do j=1,4   !! or selects one of 80,135,160,270
         i=j
         if (parm.eq.ibws2(i)) then
            if (i.eq.1.or.i.eq.2) i=2 
            if (i.eq.3.or.i.eq.4) i=3 
            goto 246
         endif
      enddo
      ierr = -209
      goto 990
246   ieq = i
250   continue
C  What we write to the tape drive is one less than the index,
C  therefore...
      ieq = ieq -1
C
C  2.5 BITRATE, PARAMETER 5
C
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if (cjchar(iparm,1).ne.','.and.cjchar(iparm,1).ne.'*') goto 251
      if (cjchar(iparm,1).eq.'*') ibr = ibr4tap
      if (cjchar(iparm,1).eq.',') then
        if (ieq.eq.0) ibr = 3    !!! 4 Mb/s
        if (ieq.eq.1) ibr = 3    !!! 4 Mb/s
        if (ieq.eq.2) ibr = 2    !!! 8 Mb/s
        if (ieq.eq.3) ibr = 3    !!! 4 Mb/s
      endif
      goto 300
251   do i=1,4          !!! ibws3/16,8,4,2/
        if (parm.eq.ibws3(i)) goto 255
      enddo
      ierr = -210
      goto 990
255   ibr = i
C
C
C
C  3. Now plant these values into COMMON.
C
300   call fs_get_icheck(icheck(18),18)
      ichold = icheck(18)
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      itrakaus_fs=ita
      itraka = ita
      call fs_set_itraka(itraka)
C
      itrakbus_fs=itb
      itrakb = itb
      call fs_set_itrakb(itrakb)
C
      ibypas = iby
      ieq4tap = ieq
      ibr4tap = ibr
C
C  4. Set up buffer for tape drive.  Send to MATCN.
C
      ibuf(1) = 0
      call char2hol('tp',ibuf(2),1,2)
      call rp2ma4(ibuf(3),iby,ieq,ita,itb)
C
      iclass = 0
      call put_buf(iclass,ibuf,-13,'fs','  ')
C
      call rpbr2ma4(ibuf(3),ibr)
      call put_buf(iclass,ibuf,-13,'fs','  ')
      nrec = 2

      call fs_get_rack(rack)
      if(rack.eq.MK4) then
         ibuf(1)=9
         if(iby.eq.0) then
            call char2hol('fm/rec 0',ibuf(2),1,8)
         else
            call char2hol('fm/rec 1',ibuf(2),1,8)
         endif
         call put_buf(iclass,ibuf,-10,'fs','  ')
         nrec = nrec+1
      endif
      goto 800
C
C
C  5. This is the read device section.
C     Fill up three class buffers, one requesting ( data (mode -3),
C     one  ) (mode -4), one ! (mode -1).
C
500   call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      ibuf(1) = -5
      call put_buf(iclass,ibuf,-4,'fs','  ')
      ibuf(1) = -7
      call put_buf(iclass,ibuf,-4,'fs','  ')
C
      nrec = 2
      goto 800
C
C
C  6. This is the test/reset device section.
C
600   ibuf(1) = 6
      call char2hol('tp',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      nrec = 1
      goto 800
C
C
C  7. This is the alarm query and reset request.
C
700   ibuf(1) = 7
      call char2hol('tp',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ')
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
      call repds4(ip,iclcm)
      return
C
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qr',ip(4),1,2)
      return
      end
