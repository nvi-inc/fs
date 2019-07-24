      program chekr
C 
C     This program steps through all of the Mark III modules
C     and checks their settings against those sent out by commands
C     or expected values.  All monitor-only values are updated in COMMON. 
C     Those modules specified in the ICHECK array in COMMON 
C     are processed.
C 
      include '../include/fscom.i'
C 
C  INPUT: 
C 
C     RMPAR - NOT USED
C 
C  SUBROUTINES CALLED:
C 
C     MATCN - to get data from the modules
C     BOSS  - to report error messages
C     LOGIT - to log and display the error
C     MA2VC - decode the MATCN buffers for VC 
C     MA2IF - decode the MATCN buffers for IF 
C     MA2FM - decode the MATCN buffers for FM 
C     MA2RP - decode the first MATCN buffer for the tape
C     MA2EN - decode the second MATCN buffer for the tape 
C     MA2TP - decode the third MATCN buffer for the tape
C     MA2MV - decode the fourth MATCN buffer for the tape 
C     MA2RX - decode
C     RXVTOT- convert MAT voltage reading to temperature
C 
C  LOCAL VARIABLES: 
      integer get_buf,ichcm_ch
      parameter (twarn=30.0)       !  temperature in k
      parameter (iagain=20)      ! repeat period for chekr (seconds)
C 
C     TIMHP1,TIMHP2 - two readings of computer time 
C     TIMEFM - reading of formatter clock time
C     TIMTOL - tolerance on comparison between formatter and HP 
C     IDAREF - reference day number, from HP, re-set every loop 
      logical kalarm
C      - true for alarm ON, i.e. NAK response from MAT
C     I - major loop counter for module number 1 to NMOD
      dimension ip(5)             ! - for RMPAR
      dimension poffx(2),pnow(2)
      real*4 scale,volt           ! - for Head Position Read-out
      integer*2 ibuf1(40),ibuf2(5),ibuf3(5),ibuf4(5)
      integer it1(13),itfm(6)
      integer*4 secs_before,secs_after,secs_fm
      integer*4 timtol,diff_before,diff_after,diff_both,timchk
      integer itbuf1(5),itbuf3(5),itbuf4(5)
      parameter (ibuf1len=40)
      parameter (ibuf2len=5)
C      - the buffers from MATCN
      integer*2 lmodna(18)
      dimension nbufs(18), icodes(4,18)
C      - MODule NAmes, 2-char codes
C      - Number of BUFfers for each module
C      - Integer CODES for MATCN for each buffer
      dimension inerr(15),icherr(169),ichecks(20)
C      - Arrays for recording identified error conditions
      integer*2 lwho       ! - mnemonic for CHEKR
      dimension it(28),lgen(2)     ! - dummy arrays for checking
      integer*2 lfr(3)
      dimension ireg(2)
      character*1 cjchar
      integer id
      integer fc_dad_pid
      equivalence (ireg(1),reg)
C
C  INITIALIZED:
C
      data timtol/100.0/
C                   Set time tolerance to 100 centi-seconds
      data lwho /2hch/
      data lmodna /2hv1,2hv2,2hv3,2hv4,2hv5,2hv6,2hv7,2hv8,2hv9,2hva,
     /             2hvb,2hvc,2hvd,2hve,2hvf,2hif,2hfm,2htp/
      data nbufs/15*2,2,2,4/
      data icodes/-1,-2,0,0,-1,-2,0,0,-1,-2,0,0,
     .            -1,-2,0,0,-1,-2,0,0,-1,-2,0,0,
     .            -1,-2,0,0,-1,-2,0,0,-1,-2,0,0,
     .            -1,-2,0,0,-1,-2,0,0,-1,-2,0,0,
     .            -1,-2,0,0,-1,-2,0,0,-1,-2,0,0,
     .            -1,-2,0,0,-53,-4,0,0,-1,-2,-3,-4/
      data nmod/18/
      data nverr,niferr,nfmerr,ntperr,maxerr /9,8,11,15,15/
      data ichecks/20*0/
      data icherr/169*0/
C
C   LAST MODIFIED    LAR  880301      USE HEAD PASS NUMBERS FROM /FSCOM/
C  WHO  WHEN    DESCRIPTION
C  GAG  910204  Changed LFEET to LFEET_FS in call to MA2TP.
C
C     1. First get our input parameters.
C
      call setup_fscom
      call read_fscom
      call rmpar(ip)
C                   We make no use of RMPAR parameters
C
C
C
C     2. Now set up the loop over the to-be-checked modules.
C     Fill up classes with requests to MATCN for data, and
C     send them out.  Do only one module at a time so as not to
C     tie up the communications.  If there is an error in MATCN
C     log it, and go on to the next module.
C
200   continue
      call fc_rte_time(itbuf1,idum)
      idaref = itbuf1(5)
C                   Get and store reference day number for comparing
C                   with formatter
C
      do 699 i=1,nmod
C
        call fs_get_icheck(icheck(i),i)
         if(icheck(i).le.0.or.ichecks(i).ne.icheck(i)) goto 699
C
          do j=1,maxerr
            inerr(j) = 0
          enddo
          do jj=1,2
            ibuf1(2) = lmodna(i)
            iclass = 0
            do j=1,nbufs(i)
              ibuf1(1) = icodes(j,i)
              call put_buf(iclass,ibuf1,-4,2Hfs,0)
            enddo
C
            ibuf1(1) = 8
            ibuf1(3) = o'47'   ! an apostrophe '
            call put_buf(iclass,ibuf1,-5,2Hfs,0)
C                   Finally, get alarm status
C
            call run_matcn(iclass,nbufs(i)+1)
C                   Send our requests to MATCN for the data
C                   Get computer time if we're checking the formatter
C
            call rmpar(ip)
            iclass = ip(1)
            nrec = ip(2)
            ierr = ip(3)
C
            if (ierr.ge.0) goto 300
            call clrcl(iclass)
          enddo
          call logit7(0,0,0,0,ierr,lwho,lmodna(i))
          goto 699
C                   There was an error in MATCN.  Log it and go on
C                   to the next module.
C
C
C
C     3. This is the VC section.
C
300   continue
C
      if (i.gt.15) goto 400
C
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      call ifill_ch(ibuf2,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      call ma2vc(ibuf1,ibuf2,lfr,ibw,itp,ia1,ia2,
     .           iremvc(i),ilokvc(i),tpivc(i),ialarm)
      call fs_set_ilokvc(ilokvc)
      call fs_set_tpivc(tpivc)
      if(iremvc(i).ne.0) inerr(1) = inerr(1) + 1
      call fs_get_lfreqv(lfreqv)
      if (ichcm(lfr,1,lfreqv(1,i),1,6).ne.0) inerr(2)=inerr(2)+1
      if (ibw.ne.ibwvc(i)) inerr(3)=inerr(3)+1
      if (itp.ne.itpivc(i)) inerr(4)=inerr(4)+1
      if (ia1.ne.iatuvc(i)) inerr(5)=inerr(5)+1
      if (ia2.ne.iatlvc(i)) inerr(6)=inerr(6)+1
      call fs_get_ilokvc(ilokvc)
      if (ilokvc(i).ne.0) inerr(7)=inerr(7)+1
      call fs_get_tpivc(tpivc)
      if (tpivc(i).eq.65535) inerr(8)=inerr(8)+1
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      kalarm = ichcm_ch(ibuf1,3,'nak').eq.0
      if (kalarm) then
        call ifill_ch(ibuf1,1,ibuf1len*2,' ')
        ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
        inerr(9)=inerr(9)+1
      endif
C
      do jj=1,nverr
        indx=(i-1)*nverr+jj
        icherr(indx)=inerr(jj)
      enddo
      goto 699
C
C     4. This is the IF distributor section.
C
400   if (i.ne.16) goto 500
C
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      call ifill_ch(ibuf2,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      call ma2if(ibuf2,ibuf1,ia1,ia2,in1,in2,tp1ifd,tp2ifd,iremif)
      if(iremif.ne.1) inerr(1)=inerr(1)+1
      if (ia1.ne.iat1if) inerr(2)=inerr(2)+1
      if (ia2.ne.iat2if) inerr(3)=inerr(3)+1
      call fs_get_inp1if(inp1if)
      if (in1.ne.inp1if) inerr(4)=inerr(4)+1
      call fs_get_inp2if(inp2if)
      if (in2.ne.inp2if) inerr(5)=inerr(5)+1
      if (tp1ifd.eq.65535) inerr(6)=inerr(6)+1
      if (tp2ifd.eq.65535) inerr(7)=inerr(7)+1
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      kalarm = ichcm_ch(ibuf1,3,'nak').eq.0
      if (kalarm) then
        call ifill_ch(ibuf1,1,ibuf1len*2,' ')
        ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
        inerr(8)=inerr(8)+1
      endif
      do jj=1,niferr
        indx=15*nverr+jj
        icherr(indx)=inerr(jj)
      enddo
      goto 699
C
C
C     5. This is the Formatter section.
C
500   if (i.ne.17) goto 600
C
      call ifill_ch(ibuf2,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      ireg(2) = get_buf(iclass,it1,-52,idum,idum)
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      call ma2fm(ibuf1,in,im,ir,isyn,itstfm,isgnfm,irunfm,
     .           iremfm,ipwrfm,ialarm)
      if(iremfm.ne.0) inerr(1)=inerr(1)+1
      if (in.ne.inpfm) inerr(2)=inerr(2)+1
      call fs_get_imodfm(imodfm)
      if (im.ne.imodfm) inerr(3)=inerr(3)+1
      call fs_get_iratfm(iratfm)
      if (ir.ne.iratfm) inerr(4)=inerr(4)+1
      if (isyn.ne.isynfm) inerr(5)=inerr(5)+1
      if (itstfm.ne.0) inerr(6)=inerr(6)+1
      if (ipwrfm.ne.0) inerr(7)=inerr(7)+1
      if (irunfm.ne.0) inerr(8)=inerr(8)+1
      itfm(6)=ias2b(ibuf1,4,1)+(iyrctl_fs/10)*10
      itfm(5)=ias2b(ibuf1,5,3)
      itfm(4)=ias2b(ibuf2,3,2)
      itfm(3)=ias2b(ibuf2,5,2)
      itfm(2)=ias2b(ibuf2,7,2)
      itfm(1)=ias2b(ibuf2,9,2)
      call rte2secs(it1,secs_before)
      call rte2secs(itfm,secs_fm)
      call rte2secs(it1(7),secs_after)
      diff_before=(secs_fm-secs_before)*100+itfm(1)-it1(1)
      diff_after=(secs_after-secs_fm)*100+it1(7)-itfm(1)
      diff_both=diff_after+diff_before
      call fs_get_ibmat(ibmat)
      timchk=timtol+it1(13)      !add in the time-out in use
      if(diff_both.gt.2*timchk) then
        inerr(9)=inerr(9)+icherr(15*nverr+niferr+9)+1
      else if(diff_before.gt.timchk.or.diff_after.lt.-timchk) then
         inerr(10)=inerr(10)+1
      endif
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      kalarm = ichcm_ch(ibuf1,3,'nak').eq.0
      if (kalarm) then
        call ifill_ch(ibuf1,1,ibuf1len*2,' ')
        ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
        inerr(11)=inerr(11)+1
      endif
      do jj=1,nfmerr
        indx=15*nverr+niferr+jj
        icherr(indx)=inerr(jj)
      enddo
      goto 699
C
C
C     6. This is the tape section.
C
600   if (i.ne.18) goto 699
C
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      call ifill_ch(ibuf2,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      call ifill_ch(ibuf3,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf3,-10,idum,idum)
      call ifill_ch(ibuf4,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf4,-10,idum,idum)
      call ma2rp(ibuf1,iremtp,iby,ieq,ibw,ita,itb,ialarm)
      call fs_set_iremtp(iremtp)
      call ma2en(ibuf2,iena  ,it,nt)
      call ma2tp(ibuf3,ilowtp,lfeet_fs,ifastp,icaptp,istptp,itactp,
     .           irdytp)
      call fs_set_icaptp(icaptp)
      call fs_set_itactp(itactp)
      call fs_set_irdytp(irdytp)
      call fs_set_istptp(istptp)
      call fs_set_lfeet_fs(lfeet_fs)
      call ma2mv(ibuf4,idir,isp,lgen)
      ierr = 0
      ntrks = 0
      do k=1,28
        if (it(k).eq.itrken(k)) then
          if (it(k).eq.1) ntrks=ntrks+1
        else
          ierr = -1
        endif
      enddo
      if(iremtp.ne.0) inerr(1)=inerr(1)+1
      if (kmvtp_fs) then
        call fs_get_idirtp(idirtp)
        call fs_get_ispeed(ispeed)
        if (isp.ne.ispeed) then
          if (ispeed.eq.0) inerr(2)=inerr(2)+1
          if (ispeed.gt.0) inerr(3)=inerr(3)+1
        else if (isp.ne.0.and.idir.ne.idirtp) then
          inerr(4)=inerr(4)+1
        endif
        call fs_get_irdytp(irdytp)
        call fs_get_khalt(khalt)
        if (.not.khalt.and.irdytp.ne.0) inerr(11)=inerr(11)+1
        if (ichcm_ch(lgen,1,'720').ne.0.and.
     .      ichcm_ch(lgen,1,'880').ne.0) inerr(12)=inerr(12)+1
      endif
      call fs_get_ienatp(ienatp)
      if(kentp_fs.or.kmvtp_fs) then
        if (ienatp.ne.iena) inerr(15)=inerr(15)+1
        if (ierr.ne.0) inerr(5)=inerr(5)+1
      endif
      if(kentp_fs.and.kmvtp_fs) then
        if (ispeed.ne.0.and.ienatp.ne.0.and.ntrks.eq.0)
     &    inerr(13)=inerr(13)+1
      endif
      if (krptp_fs) then
        if (ibw.ne.ibwtap) inerr(6)=inerr(6)+1
        if (ieq.ne.ieqtap) inerr(7)=inerr(7)+1
        if (iby.ne.ibypas) inerr(8)=inerr(8)+1
        call fs_get_itraka(itraka)
        if (ita.ne.itraka) inerr(9)=inerr(9)+1
        call fs_get_itrakb(itrakb)
        if (itb.ne.itrakb) inerr(10)=inerr(10)+1
      endif
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      kalarm = ichcm_ch(ibuf1,3,'nak').eq.0
      if (.not.kalarm) goto 635
        call ifill_ch(ibuf1,1,ibuf1len*2,' ')
        ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
        inerr(14)=inerr(14)+1
635   do jj=1,ntperr
        indx=15*nverr+niferr+nfmerr+jj
        icherr(indx)=inerr(jj)
      enddo
      goto 699
C
690   continue
      goto 699
C
C
C      This is the end of the checking loop over modules. 
C 
695   call clrcl(iclass)
699   continue
C
C     7. This is the error-reporting section.  The array ICHERR is
C     examined to determine which error messages, if any, should
C     be logged and displayed.
C
C  VC error reporting
C
      do 720 i=1,15
        indx=(i-1)*nverr+1
        call fs_get_icheck(icheck(i),i)
cxx      write(6,9000) i,icheck(i),ichecks(i)
cxx9000  format(25x,"the i icheck ichecks: ",3i10)
        if(icheck(i).le.0.or.ichecks(i).ne.icheck(i)) goto 720
        if(icherr(indx).ne.0) then
          call logit7(0,0,0,0,-301,lwho,lmodna(i))
          goto 720
        endif
        nerr=0
        do j=1,nverr-1
          if(icherr(indx+j).gt.0)nerr=nerr+1
        enddo
cxx      write(6,9100) nerr,nverr,lmodna(i)
cxx9100  format(25x,"nerr,nverr,lmodna ",i10,i10," ",a,/)
        if(nerr.gt.nverr/2) then
          call logit7(0,0,0,0,-310,lwho,lmodna(i))
          goto 720
        endif
        do j=1,nverr-1
          if(icherr(indx+j).gt.0)
     .      call logit7(0,0,0,0,-301-j,lwho,lmodna(i))
        enddo
720   continue
C
C  IFD error reporting
C
      indx=indx+nverr
      call fs_get_icheck(icheck(16),16)
      if(icheck(16).le.0.or.ichecks(16).ne.icheck(16)) goto 750
      if(icherr(indx).ne.0) then
        call logit7(0,0,0,0,-311,lwho,lmodna(16))
        goto 750
      endif
      nerr=0
      do j=1,niferr-1
        if(icherr(indx+j).gt.0) nerr=nerr+1
      enddo
      if(nerr.gt.niferr/2) then
        call logit7(0,0,0,0,-319,lwho,lmodna(16))
        goto 750
      endif
      do j=1,niferr-1
        if(icherr(indx+j).gt.0)
     .  call logit7(0,0,0,0,-311-j,lwho,lmodna(16))
      enddo
C
C  Formatter error reporting
C
750   continue
      indx=indx+niferr
      call fs_get_icheck(icheck(17),17)
      if(icheck(17).le.0.or.ichecks(17).ne.icheck(17)) goto 780
      if(icherr(indx).ne.0) then
        call logit7(0,0,0,0,-320,lwho,lmodna(17))
        goto 780
      endif
      nerr=0
      do j=1,nfmerr-1
        if(icherr(indx+j).gt.0) nerr=nerr+1
      enddo
      if(nerr.gt.nfmerr/2) then
        call logit7(0,0,0,0,-331,lwho,lmodna(17))
        goto 780
      endif
      do j=1,nfmerr-1
        if((j.ne.8.and.icherr(indx+j).gt.0).or.
     &     (j.eq.8.and.icherr(indx+j).gt.1)    )
     .  call logit7(0,0,0,0,-320-j,lwho,lmodna(17))
      enddo
C
C  Tape drive error reporting
C
780   continue
      call fs_get_icheck(icheck(18),18)
      if(icheck(18).le.0.or.ichecks(18).ne.icheck(18)) goto 800
      indx=indx+nfmerr
      if(icherr(indx).ne.0) then
        call logit7(0,0,0,0,-332,lwho,lmodna(18))
        goto 800
      endif
      nerr=0
      do j=1,ntperr-1
        if(icherr(indx+j).gt.0) nerr=nerr+1
      enddo
      if(nerr.gt.ntperr/2) then
        call logit7(0,0,0,0,-347,lwho,lmodna(18))
        goto 800
      endif
      do j=1,ntperr-1
        if(icherr(indx+j).gt.0)
     .  call logit7(0,0,0,0,-332-j,lwho,lmodna(18))
      enddo
C
C     8. Now we're going to check out the receiver.
C********************************************************************
C**NOTE: THIS SECTION IS USED ONLY AT STATIONS USING NEW COOLED RECEIVERS
C*********************************************************************
800    continue
       call fs_get_icheck(icheck(19),19)
       if(icheck(19).le.0.or.ichecks(19).ne.icheck(19)) goto 1000
       do 805 i=1,3
         inerr(i) = 0
805    continue
C
C
       ibuf1(1) = 0
       call char2hol('rx',ibuf1(2),1,2)
       call rx2ma(ibuf1(3),lswcal,0,idchrx,ibxhrx,ifamrx,2H1e)
       iclass = 0
       call put_buf(iclass,ibuf1,-12,2Hfs,0)
       ibuf1(1)=-1
       call put_buf(iclass,ibuf1,-4,2Hfs,0)
       ibuf1(1)=0
       call rx2ma(ibuf1(3),lswcal,0,idchrx,ibxhrx,ifamrx,2H1f)
       call put_buf(iclass,ibuf1,-12,2Hfs,0)
       ibuf1(1)=-1
       call put_buf(iclass,ibuf1,-4,2Hfs,0)
C
       call run_matcn(iclass,4)
       call rmpar(ip)
       iclass = ip(1)
       ierr = ip(3)
C
       if(ierr.ge.0) goto 810
         call clrcl(iclass)
         call logit7(0,0,0,0,ierr,lwho,2Hrx)
         goto 880
 810   continue
       call ifill_ch(ibuf3,1,ibuf2len*2,' ')
       ireg(2) = get_buf(iclass,ibuf3,-10,idum,idum)
       call ifill_ch(ibuf3,1,ibuf2len*2,' ')
       ireg(2) = get_buf(iclass,ibuf3,-10,idum,idum)
       call ifill_ch(ibuf2,1,ibuf2len*2,' ')
       ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
       call ifill_ch(ibuf2,1,ibuf2len*2,' ')
       ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
       call ma2rx(ibuf3(2),idum,idum,idum,idum,idum,v20k)
       call ma2rx(ibuf2(2),ilo,idum,idum,idum,idum,v70k)
       call rxvtot(31,v20k,t20k)
       call rxvtot(32,v70k,t70k)
C
C   Now compare values with acceptable limits
       if(ilo.ne.1) inerr(1) = inerr(1)+1
       if(t70k.gt.i70kch) inerr(2) = inerr(2)+1
       if(t20k.gt.i20kch) inerr(3) = inerr(3)+1
C
       call fs_get_icheck(icheck(19),19)
       if(icheck(19).le.0.or.ichecks(19).ne.icheck(19)) goto 880
       do 899 i=1,3
         if(i.eq.1) item=0
         if(i.eq.2) item=i70kch
         if(i.eq.3) item=i20kch
         if(inerr(i).ge.1) call logit7(0,0,0,1,-347-i,lwho,item)
 899   continue
 880   ibuf1(1)=0
       call rx2ma(ibuf1(3),lswcal,0,idchrx,ibxhrx,ifamrx,iadcrx)
       iclass=0
       call put_buf(iclass,ibuf1,-12,2Hfs,0)
       call run_matcn(iclass,1)
       call rmpar(ip)
       iclass=ip(1)
       call clrcl(iclass)
C
C    10. Check tape head positioning.
C
1000   continue
       call fs_get_icheck(icheck(20),20)
       if (icheck(20).le.0.or.ichecks(20).ne.icheck(20)) goto 900
C
1005   continue
       call lvdonn('lock',ip)
       if (ip(3).ne.0) then
         call logit7(0,0,0,0,ip(3),lwho,2Hhd)
         goto 1091
       endif
       call fs_get_ipashd(ipashd)
       do 1090 i=1,2
         if(kposhd_fs(i)) then
           inerr(1) = 0
             call vlt_head(i,volt,ip)
             if (ip(3).ne.0) then
               call logit7(0,0,0,0,ip(3),lwho,2Hhd)
               goto 1091
             endif
             call vlt2mic(i,ipashd(i),volt,pnow(i),ip)
             if (ip(3).ne.0) then
               call logit7(0,0,0,0,ip(3),lwho,2Hhd)
               goto 1091
             endif
             poffx(i) = pnow(i) - posnhd(i)
             if(volt.lt.-0.010) then
               scale=rslope(i)
             else if(volt.gt.0.010)then
               scale=pslope(i)
             else
               scale=max(pslope(i),rslope(i))
             endif
             if (abs(poffx(i)).gt.((ilvtl_fs+2)*0.0049+0.0026)*scale)
     &          inerr(1) = inerr(1)+1
           call fs_get_icheck(icheck(20),20)
           if(icheck(20).gt.0.and.ichecks(20).eq.icheck(20)) then
             if (inerr(1).ge.1) call logit7(0,0,0,0,-350-i,lwho,2Hhd)
           endif
         endif
1090   continue
C
C  Turn off LVDT Oscillator
C
1091  continue
      call lvdofn('unlock',ip)
      if(ip(3).ge.0) goto 1092
      call logit7(0,0,0,0,ip(3),lwho,2Hhd)
1092  continue
C
C     9. Once we are finished, take a breather for 20 seconds.
C
900   continue
      do i=1,20
        call fs_get_icheck(icheck(i),i)
        ichecks(i)=icheck(i)
      enddo
c     call susp(2,iagain)
      call wait_relt('chekr',ip,2,iagain)
      call read_quikr
      if (fc_dad_pid().ne.0) then
        do i=1,20
          call fs_get_icheck(icheck(i),i)
          ichecks(i)=icheck(i)
        enddo
      endif
      goto 200
C
      end
