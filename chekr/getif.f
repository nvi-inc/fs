      subroutine getif(iclass,nverr,niferr,icherr)
C
      include '../include/fscom.i'
C 
C  INPUT: 
C 
      integer icherr(1)
      integer nverr,niferr
C 
C  SUBROUTINES CALLED:
C 
C     MA2IF - decode the MATCN buffers for IF 
C 
C  LOCAL VARIABLES: 
      integer get_buf,ichcm_ch
C 
      logical kalarm
C      - true for alarm ON, i.e. NAK response from MAT
      integer*2 ibuf1(40),ibuf2(5)
      integer inerr(8)
      parameter (ibuf1len=40)
      parameter (ibuf2len=5)
      dimension ireg(2)
      equivalence (ireg(1),reg)
C
C  INITIALIZED:
C
      do i=1,8
        inerr(i)=0
      enddo
      call ifill_ch(ibuf1,1,ibuf1len*2,' ')
      ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
      call ifill_ch(ibuf2,1,ibuf2len*2,' ')
      ireg(2) = get_buf(iclass,ibuf2,-10,idum,idum)
      call ma2if(ibuf2,ibuf1,ia1,ia2,in1,in2,tp1ifd,tp2ifd,iremif)
      mifd_tpi(1)=nint(tp1ifd)
      call fs_set_mifd_tpi(mifd_tpi,1)
      mifd_tpi(2)=nint(tp2ifd)
      call fs_set_mifd_tpi(mifd_tpi,2)
      if(iremif.ne.1) inerr(1)=inerr(1)+1
      call fs_get_iat1if(iat1if)
      if (ia1.ne.iat1if) inerr(2)=inerr(2)+1
      call fs_get_iat2if(iat2if)
      if (ia2.ne.iat2if) inerr(3)=inerr(3)+1
      call fs_get_inp1if(inp1if)
      if (in1.ne.inp1if) inerr(4)=inerr(4)+1
      call fs_get_inp2if(inp2if)
      if (in2.ne.inp2if) inerr(5)=inerr(5)+1
      if (tp1ifd.ge.65534.5) inerr(6)=inerr(6)+1
      if (tp2ifd.ge.65534.5) inerr(7)=inerr(7)+1
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
C
      return
      end
