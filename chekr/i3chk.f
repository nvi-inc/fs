      subroutine i3chk(ichecks,lwho)
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
C     MA2I3 - decode
C 
C  LOCAL VARIABLES: 
      integer get_buf
      integer ni3err
      parameter (ni3err=11)
      integer inerr(ni3err)
C 
      integer*4 ip(5)             ! - for RMPAR
      integer*2 ibuf1(40),ibuf2(5)
      parameter (ibuf1len=40)
      parameter (ibuf2len=5)
C      - Arrays for recording identified error conditions
      integer ireg(2),isw(4)
      integer*4 freq
      logical kalarm,kbit
      integer rn_take
C
C  INITIALIZED:
C
c
      do i=1,ni3err
        inerr(i)=0
      enddo
      call char2hol('i3',ibuf1(2),1,2)
      iclass = 0
      ibuf1(1)=-1
      call put_buf(iclass,ibuf1,-4,'fs','  ')
      ibuf1(1)=-2
      call put_buf(iclass,ibuf1,-4,'fs','  ')
      ibuf1(1)=8
      call char2hol(''' ',ibuf1(3),1,1)
      call put_buf(iclass,ibuf1,-5,'fs','  ')
C
      ierr=rn_take('fsctl',0)
      call run_matcn(iclass,3)
      call rn_put('fsctl')
      call rmpar(ip)
      iclass = ip(1)
      ierr = ip(3)
C
      if (ierr.lt.0) then
        call clrcl(iclass)
        call logit7ic(0,0,0,0,ierr,lwho,'i3')
        goto 880
      endif
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      call ma2i3(ibuf1,ibuf2,iat,imix,isw(1),isw(2),isw(3),isw(4),
     &                iswp,freq,irem,ilo,tpi)
C
C Now compare values with acceptable limits
      if(irem.ne.1)          inerr(1)=inerr(1)+1
      if(iat.ne.iatif3_fs)   inerr(2)=inerr(2)+1
      if(imix.ne.imixif3_fs) inerr(3)=inerr(3)+1
      iswc=0
      do i=1,4
         if(kbit(iswavif3_fs,i)) then
           iswc=iswc+1
           if(isw(i).ne.iswif3_fs(i)) inerr(3+i)=inerr(3+i)+1
         endif
      enddo
      if(freq.ne.freqif3_fs) inerr(8)=inerr(8)+1
      if(ilo.ne.1) inerr(9) = inerr(9)+1
      if(tpi.gt.65534.5) inerr(10)=inerr(10)+1
c
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      kalarm = ichcm_ch(ibuf1,3,'nak').eq.0
      if (kalarm) then
        ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
        inerr(11)=inerr(11)+1
      endif
C
      call fs_get_icheck(icheck(21),21)
      if(icheck(21).le.0.or.ichecks(21).ne.icheck(21)) goto 880
      if(inerr(1).ne.0) then
        call logit7ic(0,0,0,0,-361,lwho,'i3')
        goto 880
      endif
      nerr=0
      do j=2,ni3err
        if(inerr(j).gt.0) nerr=nerr+1
      enddo
      if(nerr.gt.(ni3err-4+iswc)/2) then
        call logit7ic(0,0,0,0,-360,lwho,'i3')
        goto 880
      endif
      do j=2,ni3err
        if(inerr(j).gt.0)
     .  call logit7ic(0,0,0,0,-360-j,lwho,'i3')
      enddo
880   continue
C
      return
      end
