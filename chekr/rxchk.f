      subroutine rxchk(ichecks,lwho)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer ichecks(1)
      integer*2 lwho
C 
C  SUBROUTINES CALLED:
C 
C     MATCN - to get data from the modules
C     LOGIT - to log and display the error
C     MA2RX - decode
C     RXVTOT- convert MAT voltage reading to temperature
C 
C  LOCAL VARIABLES: 
      integer get_buf
      integer inerr(3)
      integer rn_take
C 
      dimension ip(5)             ! - for RMPAR
      integer*2 ibuf1(40),ibuf2(5),ibuf3(5)
      parameter (ibuf1len=40)
      parameter (ibuf2len=5)
C      - Arrays for recording identified error conditions
      dimension ireg(2)
      equivalence (ireg(1),reg)
C
C  INITIALIZED:
C
      do i=1,3
        inerr(i)=0
      enddo
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
      ierr=rn_take('fsctl',0)
      call run_matcn(iclass,4)
      call rn_put('fsctl')
      call rmpar(ip)
      iclass = ip(1)
      ierr = ip(3)
C
      if (ierr.lt.0) then
        call clrcl(iclass)
        call logit7(0,0,0,0,ierr,lwho,2Hrx)
        goto 880
      endif
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
C Now compare values with acceptable limits
      if(ilo.ne.1) inerr(1) = inerr(1)+1
      if(t70k.gt.i70kch) inerr(2) = inerr(2)+1
      if(t20k.gt.i20kch) inerr(3) = inerr(3)+1
C
      call fs_get_icheck(icheck(19),19)
      if(icheck(19).le.0.or.ichecks(19).ne.icheck(19)) goto 880
      do i=1,3
        if(i.eq.1) item=0
        if(i.eq.2) item=i70kch
        if(i.eq.3) item=i20kch
        if(inerr(i).ge.1) call logit7(0,0,0,1,-347-i,lwho,item)
      enddo
880   continue
      ibuf1(1)=0
      call rx2ma(ibuf1(3),lswcal,0,idchrx,ibxhrx,ifamrx,iadcrx)
      iclass=0
      call put_buf(iclass,ibuf1,-12,2Hfs,0)
      ierr=rn_take('fsctl',0)
      call run_matcn(iclass,1)
      call rn_put('fsctl')
      call rmpar(ip)
      iclass=ip(1)
      call clrcl(iclass)
C
      return
      end
