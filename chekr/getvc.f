      subroutine getvc(iclass,nverr,icherr,iloop)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer nverr
      integer icherr(1)
      integer iloop
C 
C  SUBROUTINES CALLED:
C 
C     MA2VC - decode the MATCN buffers for VC 
C 
C  LOCAL VARIABLES: 
      integer inerr(9)
      integer get_buf,ichcm_ch
      logical kalarm
C      - true for alarm ON, i.e. NAK response from MAT
      integer*2 ibuf1(40),ibuf2(5)
      parameter (ibuf1len=40)
      parameter (ibuf2len=5)
C      - Arrays for recording identified error conditions
      integer*2 lfr(3)
      dimension ireg(2)
      equivalence (ireg(1),reg)
C
C  INITIALIZED:
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920930  Created by taking the code out of chekr.
C
      do i=1,9
        inerr(i)=0
      enddo
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      call ifill_ch(ibuf2,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      call ma2vc(ibuf1,ibuf2,lfr,ibw,itp,ia1,ia2,
     .           iremvc(iloop),ilokvc(iloop),tpivcl,ialarm)
      call fs_set_ilokvc(ilokvc)
      tpivc(iloop)=nint(tpivcl)
      call fs_set_tpivc(tpivc,iloop)
      if(iremvc(iloop).ne.0) inerr(1) = inerr(1) + 1
      call fs_get_lfreqv(lfreqv)
      if (ichcm(lfr,1,lfreqv(1,iloop),1,6).ne.0) inerr(2)=inerr(2)+1
      call fs_get_ibwvc(ibwvc)
      if (ibw.ne.ibwvc(iloop)) inerr(3)=inerr(3)+1
      call fs_get_itpivc(itpivc)
      if (itp.ne.itpivc(iloop)) inerr(4)=inerr(4)+1
      if (ia1.ne.iatuvc(iloop)) inerr(5)=inerr(5)+1
      if (ia2.ne.iatlvc(iloop)) inerr(6)=inerr(6)+1
      call fs_get_ilokvc(ilokvc)
      if (ilokvc(iloop).ne.0) inerr(7)=inerr(7)+1
      if (tpivcl.ge.65534.5) inerr(8)=inerr(8)+1
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
        indx=(iloop-1)*nverr+jj
        icherr(indx)=inerr(jj)
      enddo
C
      return
      end
