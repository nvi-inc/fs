      subroutine stdis(ip,iclcm)
C  start tape display c#870115:04:42# 
C 
      include '../include/fscom.i'
      dimension ip(1) 
      dimension ireg(2) 
      integer get_buf
      integer*2 ibuf(20),ibuf2(50)
      integer it(28)
      logical kdata,kcom
      equivalence (ireg(1),reg) 
      data ilen/40/,ilen2/100/
C 
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920715  Added new common variable lgen for rate generator.
C  gag  920727  Added code for Mark IV enable.
C 
C     1. This is the display section for the ST command.
C     Get class buffer with command in it.  Set up first part 
C     of output buffer.  Get first buffer from MATCN. 
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
      if (ierr.lt.0) return 
      if (iclass.eq.0) return 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen2,idum,idum)
C                   Get command buffer
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = nch.eq.0
      if (nch.eq.0) nch=nchar+1 
      nch = ichmv(ibuf2,nch,2h/ ,1,1) 
C                   Put / to indicate a response
      if (kdata) goto 230 
      if (kcom) goto 320
C 
      do 220 i=1,ncrec
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        if (nch+ireg(2)-2.gt.ilen2) goto 220
        if (i.ne.1) nch=mcoma(ibuf2,nch)
        nch = ichmv(ibuf2,nch,ibuf(2),1,ireg(2)-2)
220     continue
      goto 500
C 
230   ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
C                   Get response to query of ST 
      call ma2mv(ibuf,idir,isp,lgen)
      call fs_set_lgen(lgen)
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      call fs_get_drive(drive)
      if (MK4.eq.iand(MK4,drive)) then
        ia = ia2hx(ibuf,3)
        iena = iand(ia,8)/8
      else
        call ma2en(ibuf,iena,it,nt) 
      endif
      goto 350
320   isp = ispeed
      idir = idirtp 
      iena = ienatp 
C                   Get speed and direction and record status from common 
C 
350   nch = itped(-2,idir,ibuf2,nch,ilen2)  
      nch = mcoma(ibuf2,nch)
      nch = itped(-1,isp,ibuf2,nch,ilen2) 
      nch = mcoma(ibuf2,nch)
      nch = itped(-10,iena,ibuf2,nch,ilen2) 
C                   Encode speed and direction into response
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qs',ip(4),1,2)
      return
      end 
