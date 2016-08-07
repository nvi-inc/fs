      subroutine rdbe_equip(idcb,name,ip,ierr_num)
      integer idcb(2),ierr_num
      character*(*) name
      integer*4 ip(5)
c
      integer ierr,idum,ilen,ich,ic1,ic2,line
      integer*2 ibuf(50)
      double precision das2b
c
      include '../include/fscom.i'
c
      call fmpopen(idcb,name,ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,ierr_num,'bo',ierr)
        goto 995
      endif
c
      line=0
C
C  target RMS
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      rdbe_rms_t = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_rdbe_rms_t(rdbe_rms_t)
C
C RMS lower limit
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      rdbe_rms_min = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_rdbe_rms_min(rdbe_rms_min)
C
C RMS upper limit
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen) 
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      rdbe_rms_max = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) goto 990
      call fs_set_rdbe_rms_max(rdbe_rms_max)

C
C RMS upper limit
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen) 
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      if(ichcm_ch(ibuf,ic1,'raw').eq.0.and.ic2-ic1+1.eq.3) then
         rdbe_pcal_amp='r'
      else if(ichcm_ch(ibuf,ic1,'normalized').eq.0.and.
     &        ic2-ic1+1.eq.10) then
         rdbe_pcal_amp='n'
      else if(ichcm_ch(ibuf,ic1,'correlator').eq.0.and.
     &        ic2-ic1+1.eq.10) then
         rdbe_pcal_amp='c'
      else 
         goto 990
      endif
      call fs_set_rdbe_pcal_amp(rdbe_pcal_amp)
      call fmpclose(idcb,ierr)
      return
C
 990  continue
      call logit7ci(0,0,0,1,ierr_num-1,'bo',line)
 995  continue
      ip(3)=-1
      return
      end
