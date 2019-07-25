      subroutine getfm(iclass,nverr,niferr,nfmerr,icherr)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer nverr, niferr, nfmerr
      integer icherr(1)
C 
C  SUBROUTINES CALLED:
C 
C     MA2FM - decode the MATCN buffers for FM 
C 
C  LOCAL VARIABLES: 
      integer get_buf,ichcm_ch
C 
C     TIMTOL - tolerance on comparison between formatter and HP 
      integer inerr(11)
      logical kalarm
C      - true for alarm ON, i.e. NAK response from MAT
      integer*2 ibuf1(40),ibuf2(5)
      integer itfm(6)
      integer*4 secs_before,secs_after,secs_fm
      integer*4 timtol,diff_before,diff_after,diff_both
      integer*4 centisec(2)
      parameter (ibuf1len=40)
      parameter (ibuf2len=5)
C      - Arrays for recording identified error conditions
      dimension ireg(2)
      equivalence (ireg(1),reg)
C
C  INITIALIZED:
C
      data timtol/100/
C                   Set time tolerance to 100 centi-seconds
C
      do i=1,11
        inerr(i)=0
      enddo
      call ifill_ch(ibuf2,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      ireg(2) = get_buf(iclass,centisec,-8,idum,idum)
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
      call fc_rte_fixt(secs_before,centisec(1))
      call fc_rte2secs(itfm,secs_fm)
      call fc_rte_fixt(secs_after,centisec(2))
c
      diff_before=(secs_fm-secs_before)*100+itfm(1)-centisec(1)
      diff_after=(secs_after-secs_fm)*100+centisec(2)-itfm(1)
      diff_both=diff_after+diff_before
c
      if(diff_both.gt.2*timtol) then
        inerr(9)=inerr(9)+icherr(15*nverr+niferr+9)+1
      else if(diff_before.lt.-timtol.or.diff_after.lt.-timtol) then
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
C
      return
      end
