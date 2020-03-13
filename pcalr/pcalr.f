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
      program pcalr
C 
C     This program uses the data buffer to get Mark III 
C     data and then extracts the phase cal information. 
C 
C     MODIFICATIONS:
C     current programmer - Molly Hardman
C       DATE   WHO   DESCRIPTION
C      820222  MAH   Adding subroutines 
C 
C 
C 
C  CALLING PARAMETERS:
C     INPUT:
C 
C     From FS common or prompts to the user 
C 
C     OUTPUT: 
C 
C     Phase cal amplitude and phase typed out on terminal 
C     by track number.
C 
C 
C  SUBROUTINES CALLED:
C 
C     MODET - determine in what mode PCALR should be run
C     TPSET - sets up tracks on tape recorder 
C     DBCOM - handles communications with data buffer 
C     DPROX - processes data buffer data
C     PCALX - extracts phase cal
C     PHCAL - determines phase cal freq by track
C     BPSET - sets tracks and IBYPPC as requested 
C 
C 
      include '../include/fscom.i'
C 
C  LOCAL VARIABLES: 
C 
C     ITRK - current track being processed
C     IC - loop counter over PCALR
C     ITKA - holds value of ITRAKA for later checking 
C     ITKB - holds value of ITRAKB for later checking 
C     IBYPCH - holds value of IBYPPC for later checking 
C     IHOLD - value of ICHECK(18) 
C     INIT - flag set to 1 except for very 1st time thru' PCALR 
C     IVC - video converter corresponding to ITRAKB 
C     IVC2 - video converter corresponding to ITRAKA
C     IBLOKN - block # sent from data buffer
C     LWHO - code for error messages
C     ILOG - # characters in raw IDATA

      integer*2 idata(260)     ! the data 
      integer*4 ibaudl       ! long baud for portopen
      integer portopen
      integer rn_take
      real resp(2)
      integer*2 levset(2)
      integer*2 ibuf(625)
C      - buffer for MAT and DB commands, and working buffer too
C      - Contains flag information for PCAL
      integer*2 ltime(8)
C      - time characters from data buffer, if any occurred
      real bwdi(8)        ! the possible sample rates
      integer idcb(2)      ! DCB for the test data file.
      integer*4 ip(5)          ! RMPAR variables
      double precision pcal,pcala
      double precision rsina,rsinb,rcosa,rcosb,rnbita,rnbitb
      logical kfield,kdbuff,ksplit,kcount,kcorel,ksa,kbreak
C      - KFIELD, true if FS is running
C      - KDBUFF, true if we have a real data buffer
C      - KSPLIT, true if we are to run in split mode
C      - KCOUNT, loop counter over PCALR
C      - KCOREL, true if data was correlated
C      - KSA,    true if we are to use spectrum analyzer
C
C  INITIALIZED:
C
      data bwdi/8.0,0.0,0.125,0.25,0.5,1.0,2.0,4.0/
      data lwho/2Hpc/
      data levset/2Has,2H--/
c     data oflw/1.e+10/
C
C
C   1. First get PCALR mode by calling MODET.  If the FS
C     is not running, MODET prompts for needed input parameters.
C     Set up the data buffer interface if this is the
C     first pass thru' PCALR (i.e. INIT=0).
C
      call setup_fscom
      call fmperror_standalone_set(1)
      call putpname('pcalr')
1     continue
      call wait_prog('pcalr',ip)
2     continue
      if(kbreak('pcalr')) goto 2
      if(0.ne.rn_take('pcalr',1)) then
        call logit7cc(idum,idum,idum,-1,-8,'pc','er')
        goto 1
      endif
      call read_fscom
c
      init = 0
      kfield = .true.
100   kdbuff = .true.
      kcount = .true.
      ksplit = .false.
      kcorel = .false.
C     - initialize logical variables
      ksa = .false.
      if (ichcm_ch(ip(1),1,'sa').eq.0) ksa = .true.
      if (init.eq.0) call modet(kfield,kdbuff,ksplit,luop,pcal,pcala,
     .      idcb,iquit,ierr,ksa)
      if (ierr.eq.-1) goto 990
      if (.not.kdbuff.or.init.eq.1) goto 105
C
C           Skip this if we don't have a real data buffer
C             or if it has been done before
C
      ibaudl=ibdb
      iparity=0
      idbits=8
      istop=1
      if(ibdb.eq.110) istop=2
      ierr=portopen(ludb,idevdb,64,ibaudl,iparity,idbits,istop)
      if(ierr.ne.0) then
        call logit7ci(idum,idum,idum,0,ierr,'pc',0)
        goto 999
      endif
      if (ibugpc.gt.1) then
         call fs_get_ibwvc(ibwvc)
         write(luop,9110) itrack,lblk,nblkpc,ibyppc,ibwvc(1),ibdb
      endif
9110  format(1x,"parameters for phase cal extraction using data buffer"/
     ."track# "i5" block# "a2" #blks "i3" bypass mode "i2" bandwidth "
     .i2," baud rate "i5)
105   continue
      init = 1
C
C   2. Start of loop over PCALR, NCYCPC times if NCYCPC > 0
C     If NCYCPC = 0, KCOUNT is always true and the loop
C     is executed continuously until you "break" PCALR.
C     This loop encloses the loop over all tracks and an
C     inner loop over NBLKPC blocks
C
      ic = 1
110   if (ncycpc.gt.0.and.ic.gt.ncycpc) kcount = .false.
      if (.not.kcount) goto 990
      if (ibugpc.gt.1) write(luop,9510) lu,luop,lumat,ludb,lusa,ibdb
9510  format(1x,"lu,luop,lumat,ludb,lusa,ibdb"/6i5)
C
C
C
C     3. Now set up the loop over all tracks.
C     Code up the buffer for the tape drive and send it off.
C
      do 900 itrk = 1,28
        if(kbreak('pcalr')) goto 999
        if (itrkpc(itrk).le.0) goto 900
C                   Skip this track if it's not requested or setup
C     PHCAL calculates the phase cal freq in the VC corresponding
C     to ITRK.  Data from this track is not processed if PCAL>50kHz
C
      if (kfield) call phcal(pcal,itrk,ivc)
      if (ibugpc.gt.0) then
         call fs_get_freqvc(freqvc)
         write(luop,9205) pcal,itrk,ivc,freqvc(ivc)         
 9205    format(1x,"pcal (hz)="d9.2" track="i2" vc#="i2" vcfrq="f7.2)
      endif
      if (pcal.gt.50000.) goto 900
C
      if (ibugpc.gt.0) write(luop,9210) itrk
9210  format(1x," track # "i3)
      if (.not.kfield) goto 300
C           Skip MATCN call if the Field System is not running
112   call bpset(ihold,ibypch,itrk,ksplit,itka,itkb,iskip)
      if (iskip.eq.-1) goto 890
C
C      - Check phase cal in partner track if in split mode
C
      if (ksplit) then 
         call phcal(pcala,itrkpc(itrk),ivc2)
         if (ibugpc.gt.0) then
            call fs_get_freqvc(freqvc)
            write(luop,9205) pcala,itrkpc(itrk),ivc2,freqvc(ivc2)
         endif
      endif
      if (pcala.gt.50000.) ksplit = .false.
C
      if(kbreak('pcalr')) goto 999
      call tpset(ihold,ibuf,ierr,ksplit,ksa)
      if(ierr.ne.0) call logit7cc(idum,idum,idum,0,ierr,'ma','t1')
      if (ierr.ne.0) goto 990
C
C     4. Reset the data buffer and arm it.  Suspend ourselves for
C     2 seconds, wake up, check data buffer status.  If
C     data is holding, set up block desired and get the data.
C     If still armed, suspend again.
C
C     4.1  Send <esc> to say hello to the data buffer and then quit
C          if you only asked to check communications.
C
300   continue
      if(ksa) goto 500
      call pchar(ibuf,1,27)!<ESC>
      if (ibugpc.gt.1) write(luop,9310) ibuf(1)
9310  format(1x,"sending command to data buffer: "5a2)
      if(kbreak('pcalr')) goto 999
      call dbcom(luop,ludb,ibugpc,ibuf,1,idata,ilog,ierr,iblk,istat,id,
     . kdbuff,idcb,ibdb)
      if (ibugpc.ne.0) write(luop,9311) ilog,iblk,istat,id,ierr
9311  format(/,1x,"ilog="i5" iblk="i3" istat="i10" id="i10" ierr="i5)
      if (ilog.eq.-1) goto 990
      if (iquit.lt.0) goto 990
      if (ilog.ne.0) goto 303
      ierr = -103
      if (kfield) call logit7(idum,idum,idum,1,ierr,lwho,itrk)
      if (.not.kfield) write(luop,9312) itrk
9312  format(1x,"zero length record returned on track #"i2)
      goto 900
C
C     4.2  Send ":" to reset the data buffer
C
303   call ichmv_ch(ibuf,1,':')
      if (ibugpc.gt.1) write(luop,9310) ibuf(1)
      if(kbreak('pcalr')) goto 999
      call dbcom(luop,ludb,ibugpc,ibuf,1,idata,ilog,ierr,iblk,istat,id,
     . kdbuff,idcb,ibdb)
      if (ibugpc.ne.0) write(luop,9311) ilog,iblk,istat,id,ierr
      if (ilog.eq.-1) goto 990
      if (ilog.ne.0) goto 305
      ierr = -103
      if (kfield) call logit7(idum,idum,idum,1,ierr,lwho,itrk)
      if (.not.kfield) write(luop,9312) itrk
      goto 900
C
C     4.3  Send IMODE and "&" to set the data buffer mode
C
305   imode = 2
      if (ksplit) imode = 3
      ibuf(1) = ih22a(imode)
      call ichmv_ch(ibuf,3,'&')
      if (ibugpc.gt.1) write(luop,9310) ibuf(1),ibuf(2)
      if(kbreak('pcalr')) goto 999
      call dbcom(luop,ludb,ibugpc,ibuf,3,idata,ilog,ierr,iblk,istat,id,
     . kdbuff,idcb,ibdb)
      if (ibugpc.ne.0) write(luop,9311) ilog,iblk,istat,id,ierr
      if (ilog.eq.-1) goto 990
      if (ilog.ne.0) goto 307
      ierr = -103
      if (kfield) call logit7(idum,idum,idum,1,ierr,lwho,itrk)
      if (.not.kfield) write(luop,9312) itrk
      goto 900
C
C     4.4  Send "!" to arm the data buffer
C
307   call ichmv_ch(ibuf,1,'!')
      if (ibugpc.gt.1) write(luop,9310) ibuf(1)
      if(kbreak('pcalr')) goto 999
      call dbcom(luop,ludb,ibugpc,ibuf,1,idata,ilog,ierr,iblk,istat,id,
     . kdbuff,idcb,ibdb)
      if (ibugpc.ne.0) write(luop,9311) ilog,iblk,istat,id,ierr
      if (ilog.eq.-1) goto 990
      if (ilog.ne.0) goto 310
      ierr = -103
      if (kfield) call logit7(idum,idum,idum,1,ierr,lwho,itrk)
      if (.not.kfield) write(luop,9312) itrk
      goto 900
C
C     4.5  Get status every 2 seconds and check that bypass mode and
C          channel A and B tracks have not changed.
C          Go on when ISTAT is correctly set, i.e. the data buffer
C          is holding data.  (ISTAT=17 for channel B,ISTAT=25 in split mode.)
C
310   continue
      if (ibugpc.ne.0) write(luop,9300)
9300  format(1x,"suspending for 2 seconds")
      call susp(2,2)
      if (ibugpc.gt.1) write(luop,9310) ibuf(1)
      if(kbreak('pcalr')) goto 999
      call dbcom(luop,ludb,ibugpc,ibuf,1,idata,ilog,ierr,iblk,istat,id,
     . kdbuff,idcb,ibdb)
      if (ibugpc.ne.0) write(luop,9311) ilog,iblk,istat,id,ierr
      call fs_get_itrakb(itrakb,1)
      call fs_get_itraka(itraka,1)
      if (kfield.and.(ibypch.ne.ibypas(1).or.itkb.ne.itrakb(1).or.(
     . itka.ne.itraka(1).and.ksplit))) goto 112
      if (ilog.eq.-1) goto 990
      if(kbreak('pcalr')) goto 999
      if ((.not.ksplit.and.istat.eq.17).or.(ksplit.and.istat.eq.25))
     . goto 315
      if (ilog.ne.0.and.ierr.eq.0) goto 310
      if (ilog.ne.0) goto 313
      ierr = -103
      if (kfield) call logit7(idum,idum,idum,1,ierr,lwho,itrk)
      if (.not.kfield) write(luop,9312) itrk
      goto 900
313   ierr = -100+ierr
      if (kfield) call logit7(idum,idum,idum,1,ierr,lwho,itrk)
      if (.not.kfield) write(luop,9313) ierr,itrk
9313  format(1x,"error "i3" from track "i2", next track")
      goto 900
C
C     5.0  Initialize counters and do loop over blocks
C
315   rsina = 0.d0
      rsinb = 0.d0
      rcosa = 0.d0
      rcosb = 0.d0
      rnbita = 0.d0
      rnbitb = 0.d0
      isplit = 2
      if (ksplit) isplit = 1
      nloop = 2*nblkpc-1
C
      do 899 i = 0,nloop,isplit
          iblokn = i/isplit
c         iblokn = i/isplit+ 50
          ibuf(1) = ih22a(iblokn)
          call ichmv_ch(ibuf,3,'+')
          if (ibugpc.gt.1) write(luop,9310) ibuf(1),ibuf(2)
          if(kbreak('pcalr')) goto 999
          call dbcom(luop,ludb,ibugpc,ibuf,3,idata,ilog,ierr,iblk,istat,
     .    id,kdbuff,idcb,ibdb)
C                   Send "nn+" to set up block nn
          if (ibugpc.ne.0) write(luop,9311) ilog,iblk,istat,id,ierr
          if (ilog.eq.-1) goto 990
          call ichmv_ch(ibuf,1,'?')
          if (ibugpc.gt.1) write(luop,9310) ibuf(1)
          if(kbreak('pcalr')) goto 999
          call dbcom(luop,ludb,ibugpc,ibuf,1,idata,ilog,ierr,iblk,istat,
     .     id,kdbuff,idcb,ibdb)
C                   Send "?" to get the data
C
          if (ibugpc.ne.0) write(luop,9311) ilog,iblk,istat,id,ierr
          if (ilog.eq.-1) goto 990
          if (ierr.eq.0) goto 400
          if (.not.kfield) write(luop,9319) ierr
9319      format(1x," error"i3" getting data, skipping this track")
          ierr = ierr-100
          if (kfield) call logit7(idum,idum,idum,1,ierr,lwho,itrk)
          goto 900
C
C
C         6. Process the data.  Get the phase cal from it.
C         Write out the amp and phase.
C
400       call dprox(luop,ibugpc,idata(2),ilog-4,iblk,ibuf,nbytes,ipar,
     .           icrcc,ltime,ischar,ksplit)
C         Get sample rate from code in FSCOM
          call fs_get_iratfm(iratfm)
          smplrt = bwdi(iratfm+1)
          smplrt = smplrt*1.e6
          if (ibugpc.ne.0.and.icrcc.ne.0.and..not.ksplit)
     .         write(luop,9320) ltime
9320      format(1x,"ltime from dproc="8a2)
C         - accumulate RSIN,RCOS,RNBIT
          call pcalx(smplrt,iblokn,rsinb,rcosb,rnbitb,rsina,rcosa,
     .      rnbita,idata(2),ilog-4,pcal,pcala,ksplit)
          if (ibugpc.gt.1) write(luop,9530) iblokn,rsinb,rcosb,rnbitb
9530      format(/,1x," block# "i3"; rsin,rcos,rnbit = "3f8.0)
          if (ksplit) call pccor(ivc,ivc2,itrk,kcorel,idata,ilog,
     .        r1bit,nzero)
             if(kbreak('pcalr')) goto 999
899       continue
C
C
      call nrmlz(kfield,ksplit,rsinb,rcosb,rnbitb,rsina,rcosa,
     . rnbita,ivc,ivc2,itrk,kcorel,nzero,r1bit)
      goto 890
C
C     7. Measure phase cal amplitude with spectrum analyzer
C
500   continue
C  Set SA to look at 500 Hz around 10 KHz
cxx      call exec(2,lusa,24Hprs,im2,px1,mn1,mp50,av2,-24)
      call ib2as(lvsens,levset,3,o'100002')
cxx      call exec(2,lusa,levset,-3-(lvsens/10))
C Measure phase cal amp and phase with spectrum analyzer
cxx      call exec(2,lusa,6Haa1,re,-6)
      call susp(2,intamp)
      call dump('mk',resp)
      ampb = resp(1)
cxx      call exec(2,lusa,3Haa0,-3)
      call dump('mk',resp)
      phaseb = resp(1)
      call messg(kfield,ksplit,ampa,phasea,ampb,phaseb,dlyab,itrk,
     .  ivc,ivc2,kcorel,correl)
C
C
C     8. End of the loop over tracks.  Get next track from the
C     enabled list and go on.
C
890     icheck(18) = ihold
        call fs_set_icheck(icheck(18),18)
900     continue
C
C     9.  Suspend here then return to the beginning.  If at
C     the end of # of cycles requested, go dormant saving resources.
C
      ic = ic+1
C      - Suspend here for IPAUPC seconds
      call susp(2,ipaupc)
      call read_fscom
      goto 110
990   continue
      if (.not.kdbuff) call fmpclose(idcb,ierr)
      if (.not.kfield) goto 999
      call wait_prog('pcalr',ip)
      if (ip(1).eq.-1) goto 999
      goto 100
999   continue
      call putcon_ch('pcalr ended')
      call rn_put('pcalr')
      goto 1
      end
