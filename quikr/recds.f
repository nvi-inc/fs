      subroutine recds(ip,iclcm)
C  start tape display c#870115:04:42# 
C 
      include '../include/fscom.i'
      dimension ip(1) 
      dimension ireg(2) 
      integer get_buf
      integer*2 ibuf(20),ibuf2(50)
      equivalence (ireg(1),reg) 
      data ilen/40/,ilen2/100/
C 
C  HISTORY:
C  WHO  WHEN    WHAT
C 
C     1. This is the display section for the ST command.
C     Get class buffer with command in it.  Set up first part 
C     of output buffer.  Get first buffer from MATCN. 
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      if (ierr.lt.0) return 
      if (iclass.eq.0) return 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen2,idum,idum)
C                   Get command buffer
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      if (nch.eq.0) nch=nchar+1 
      nch = ichmv_ch(ibuf2,nch,'/') 
C                   Put / to indicate a response
      do 220 i=1,ncrec
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        if (nch+ireg(2)-2.gt.ilen2) goto 220
        if (i.ne.1) nch=mcoma(ibuf2,nch)
        nch = ichmv(ibuf2,nch,ibuf(2),1,ireg(2)-2)
220     continue
C
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qs',ip(4),1,2)
      return
      end 
