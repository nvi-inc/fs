      subroutine nfdis(ip,ibuf,ilen,nchar)
C 
C 1.1.   NFDIS gets data from common variables and displays them
C 
C     INPUT VARIABLES:
      dimension ip(1)
      integer*2 ibuf(1) 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # RECS 
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
C     CALLING SUBROUTINES: ONOFC
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
C        NCH    - character counter 
C 
C 6.  PROGRAMMER: MWH 
C     CREATED: 840510 
C 
C     PROGRAM STRUCTURE 
C 
C     1. First set up output buffer for response. 
C 
      nch = iscn_ch(ibuf,1,nchar,'=') 
      if (nch.eq.0) nch = nchar+1 
C                  If no "=" found position after last character
      nch = ichmv_ch(ibuf,nch,'/')  
C              Put / to indicate a response 
C 
C     2.  Fill the buffer with the required common variables
C 
      ierr = 0
      nch = nch + ib2as(nrepnf,ibuf,nch,o'100002')
      nch = mcoma(ibuf,nch) 
      nch = nch + ib2as(intpnf,ibuf,nch,o'100002')
      nch = mcoma(ibuf,nch) 
      nch = ichmv(ibuf,nch,ldv1nf,1,2)
      nch = mcoma(ibuf,nch) 
      nch = ichmv(ibuf,nch,ldv2nf,1,2)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(ctofnf*180./RPI,ibuf,nch,6,1)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(stepnf,ibuf,nch,4,1)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(cal1nf,ibuf,nch,6,1)  
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(cal2nf,ibuf,nch,6,1)  
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(bm1nf_fs*180./RPI,ibuf,nch,6,4)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(bm2nf_fs*180./RPI,ibuf,nch,6,4)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(fx1nf_fs,ibuf,nch,9,1)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(fx2nf_fs,ibuf,nch,9,1)
C 
C     5. Now send the buffer to SAM and schedule PPT. 
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,'fs','  ')
C                   Send buffer starting with info to display 
      ip(1) = iclass
      ip(2) = 1 
      call char2hol('qz',ip(4),1,2)
      return
      end 
