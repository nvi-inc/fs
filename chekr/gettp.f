      subroutine gettp(iclass,nverr,niferr,nfmerr,ntperr,icherr,indxtp)
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
      logical kalarm, kena(2)
C      - true for alarm ON, i.e. NAK response from MAT
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
      if (MK4.eq.drive(indxtp)) then
        call ma2rp4(ibuf1,iremtp,iby,ieq,ita,itb)
        call ma2en4(ibuf2,iena,kena)
      else
        call ma2rp(ibuf1,iremtp,iby,ieq,ibw,ita,itb,ialarm)
        call ma2en(ibuf2,iena  ,itc,nt)
      endif
      call ma2tp(ibuf3,ilowtp(indxtp),lfeet_fs(1,indxtp),ifastp,
     $     icaptp(indxtp),istptp(indxtp),itactp(indxtp),irdytp(indxtp))
      call fs_set_icaptp(icaptp,indxtp)
      call fs_set_itactp(itactp,indxtp)
      call fs_set_irdytp(irdytp,indxtp)
      call fs_set_istptp(istptp,indxtp)
      call fs_set_lfeet_fs(lfeet_fs,indxtp)
      call ma2mv(ibuf4,idir,isp,lchgen)
      ierr = 0
      ntrks = 0
      if (MK3.eq.drive(indxtp)) then
         do k=1,28
            if (itc(k).eq.itrken(k,indxtp)) then
               if (itc(k).eq.1) ntrks=ntrks+1
            else
               ierr = -1
            endif
         enddo
      else if(MK4.eq.drive(indxtp)) then
         call fs_get_kenastk(kenastk,indxtp)
         if(kena(1).ne.kenastk(1,indxtp) .or.
     $        kena(2).ne.kenastk(2,indxtp)) ierr=-1
         if(kena(1)) ntrks=ntrks+1
         if(kena(2)) ntrks=ntrks+1
      endif
      if (iremtp.ne.0) inerr(1)=inerr(1)+1
      if (kmvtp_fs(indxtp).or.kldtp_fs(indxtp)) then
        call fs_get_idirtp(idirtp,indxtp)
        call fs_get_ispeed(ispeed,indxtp)
        if (isp.ne.ispeed(indxtp).and.isp+ispeed(indxtp).ne.1) then
          if (ispeed(indxtp).lt.2) inerr(2)=inerr(2)+1
          if (ispeed(indxtp).gt.1) inerr(3)=inerr(3)+1
        else if ((isp.ne.0.and.idir.ne.idirtp(indxtp)).and.
     .           (idirtp(indxtp).ne.-1)) then
          inerr(4)=inerr(4)+1
        endif
        call fs_get_irdytp(irdytp,indxtp)
        call fs_get_khalt(khalt)
        if (.not.khalt.and.irdytp(indxtp).ne.0) inerr(11)=inerr(11)+1
        call fs_get_lgen(lgen,indxtp)
        if (ichcm(lchgen,1,lgen(1,indxtp),1,3).ne.0.and.
     &       isp+ispeed(indxtp).gt.1) inerr(12)=inerr(12)+1
      endif
CXX  NEED TO ADD CODE FOR VARIABLE WHICH STORES RATE GENERATOR INSTEAD
CXX  OF HARD CODING IT IN AS IN THE ABOVE STATEMENTS.
      call fs_get_ienatp(ienatp,indxtp)
      if(kentp_fs(indxtp).or.kmvtp_fs(indxtp)) then
        if (ienatp(indxtp).ne.iena) inerr(15)=inerr(15)+1
        if (ierr.ne.0) inerr(5)=inerr(5)+1
      endif
      if (kentp_fs(indxtp).and.kmvtp_fs(indxtp)) then
        if (ispeed(indxtp).gt.1.and.ienatp(indxtp).ne.0.and.ntrks.eq.0)
     &      inerr(13)=inerr(13)+1
      endif
      if (krptp_fs(indxtp)) then
        if (MK4.eq.drive(indxtp)) then
          if (ieq.ne.ieq4tap(indxtp)) inerr(7)=inerr(7)+1
        else
          if (ibw.ne.ibwtap(indxtp)) inerr(6)=inerr(6)+1
          if (ieq.ne.ieqtap(indxtp)) inerr(7)=inerr(7)+1
        endif
        if (iby.ne.ibypas(indxtp)) inerr(8)=inerr(8)+1
        call fs_get_itraka(itraka,indxtp)
        if (ita.ne.itraka(indxtp)) inerr(9)=inerr(9)+1
        call fs_get_itrakb(itrakb,indxtp)
        if (itb.ne.itrakb(indxtp)) inerr(10)=inerr(10)+1
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
