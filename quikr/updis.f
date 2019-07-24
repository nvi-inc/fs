      subroutine updis(ip,iclcm)
C  upconverter freqs display
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # RECS 
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C
C     CALLING SUBROUTINES: UPSET
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibuf2(60)
C               - input class buffer, output display buffer 
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
      dimension ireg(2) 
      real flo
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/120/
C 
C 6.  PROGRAMMER: NRV & MAH 
C     CREATED: 19820318 
C     Modify for PC 920226
C 
C     PROGRAM STRUCTURE 
C 
C     1. First get command buffer.
C 
      if (iclcm.eq.0) goto 990
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      if (nch.eq.0) nch = nchar+1 
C                  If no "=" found position after last character
      nch = ichmv(ibuf2,nch,2h/ ,1,1) 
C                  Put / to indicate a response 
C 
C     2.  Get common variables for display
C 
200   ierr = 0
      call fs_get_rack(rack)
      iend=3
      if(VLBA.eq.iand(rack,VLBA)) iend=4
      do 310 i = 1,iend
        call fs_get_frequp(flo,i-1)
        nch = nch+ir2as(flo,ibuf2,nch,8,3)
        nch = mcoma(ibuf2,nch)
310   continue
C 
C     5. Now send the buffer to class.
C 
      iclass = 0
      nch = nch - 2 
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('q*',ip(4),1,2)
990   return
      end 
