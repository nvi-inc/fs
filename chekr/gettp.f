      subroutine gettp(iclass,nverr,niferr,nfmerr,ntperr,icherr)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer nverr, niferr, nfmerr, ntperr
      integer icherr(1)
C 
C 
C  SUBROUTINES CALLED:
C 
C     MA2RP - decode the first MATCN buffer for the tape
C     MA2EN - decode the second MATCN buffer for the tape 
C     MA2TP - decode the third MATCN buffer for the tape
C     MA2MV - decode the fourth MATCN buffer for the tape 
C 
C  LOCAL VARIABLES: 
      integer get_buf,ichcm_ch
C 
      integer inerr(15)
      logical kalarm
C      - true for alarm ON, i.e. NAK response from MAT
      integer drive
      integer*2 ibuf1(40),ibuf2(5),ibuf3(5),ibuf4(5)
      parameter (ibuf1len=40)
      parameter (ibuf2len=5)
      dimension itc(28)     ! - dummy arrays for checking
      integer*2 lchgen(2)
      dimension ireg(2)
      equivalence (ireg(1),reg)
C
C  INITIALIZED:
C
      do i=1,15
        inerr(i)=0
      enddo
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      call ifill_ch(ibuf2,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      call ifill_ch(ibuf3,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf3,-10,idum,idum)
      call ifill_ch(ibuf4,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf4,-10,idum,idum)
      if (MK4.eq.and(MK4,drive)) then
        call ma2rp4(ibuf1,iby,ieq,ita,itb)
      else
        call ma2rp(ibuf1,iremtp,iby,ieq,ibw,ita,itb,ialarm)
        call fs_set_iremtp(iremtp)
      endif
      call ma2en(ibuf2,iena  ,itc,nt)
      call ma2tp(ibuf3,ilowtp,lfeet_fs,ifastp,icaptp,istptp,itactp,
     .           irdytp)
      call fs_set_icaptp(icaptp)
      call fs_set_itactp(itactp)
      call fs_set_irdytp(irdytp)
      call fs_set_istptp(istptp)
      call fs_set_lfeet_fs(lfeet_fs)
      call ma2mv(ibuf4,idir,isp,lchgen)
      ierr = 0
      ntrks = 0
      if (MK3.eq.and(MK3,drive)) then
        do k=1,28
          if (itc(k).eq.itrken(k)) then
            if (itc(k).eq.1) ntrks=ntrks+1
          else
            ierr = -1
          endif
        enddo
        if (iremtp.ne.0) inerr(1)=inerr(1)+1
      endif
      if (kmvtp_fs) then
        call fs_get_idirtp(idirtp)
        call fs_get_ispeed(ispeed)
        if (isp.ne.ispeed) then
          if (ispeed.eq.0) inerr(2)=inerr(2)+1
          if (ispeed.gt.0) inerr(3)=inerr(3)+1
        else if ((isp.ne.0.and.idir.ne.idirtp).and.
     .           (idirtp.ne.-1)) then
          inerr(4)=inerr(4)+1
        endif
        call fs_get_irdytp(irdytp)
        call fs_get_khalt(khalt)
        if (.not.khalt.and.irdytp.ne.0) inerr(11)=inerr(11)+1
        if (ichcm_ch(lchgen,1,'720').ne.0.and.
     .      ichcm_ch(lchgen,1,'880').ne.0.and. 
     .      ichcm_ch(lchgen,1,'000').ne.0.and. 
     .      ichcm_ch(lchgen,1,'853').ne.0) inerr(12)=inerr(12)+1
      endif
CXX  NEED TO ADD CODE FOR VARIABLE WHICH STORES RATE GENERATOR INSTEAD
CXX  OF HARD CODING IT IN AS IN THE ABOVE STATEMENTS.
      call fs_get_ienatp(ienatp)
      if(kentp_fs.or.kmvtp_fs) then
        if (ienatp.ne.iena) inerr(15)=inerr(15)+1
        if (ierr.ne.0) inerr(5)=inerr(5)+1
      endif
      if ((kentp_fs.and.kmvtp_fs).and.(MK3.eq.and(MK3,drive))) then
        if (ispeed.ne.0.and.ienatp.ne.0.and.ntrks.eq.0)
     &      inerr(13)=inerr(13)+1
      endif
      if (krptp_fs) then
        if (MK4.eq.and(MK4,drive)) then
          if (ieq.ne.ieq4tap) inerr(7)=inerr(7)+1
        else
          if (ibw.ne.ibwtap) inerr(6)=inerr(6)+1
          if (ieq.ne.ieqtap) inerr(7)=inerr(7)+1
        endif
        if (iby.ne.ibypas) inerr(8)=inerr(8)+1
        call fs_get_itraka(itraka)
        if (ita.ne.itraka) inerr(9)=inerr(9)+1
        call fs_get_itrakb(itrakb)
        if (itb.ne.itrakb) inerr(10)=inerr(10)+1
      endif
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      kalarm = ichcm_ch(ibuf1,3,'nak').eq.0
      if (kalarm) then
        call ifill_ch(ibuf1,1,ibuf1len*2,' ')
        ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
        inerr(14)=inerr(14)+1
      endif
      do jj=1,ntperr
        indx=15*nverr+niferr+nfmerr+jj
        icherr(indx)=inerr(jj)
      enddo
C
      return
      end
