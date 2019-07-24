      subroutine newtp(ip)
C  new tape command c#870115:04:41# 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - class
C        IP(2) - number of records
C        IP(3) - error
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES:  QUIKR
C     CALLED SUBROUTINES: character subroutines
C 
C 3.  LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(40)         !  class buffer
      integer*2 lmsg(16)         !  message response
      dimension ireg(2) 
      integer get_buf
      equivalence (ireg(1),reg) 
      data lmsg   /2h"t,2ho ,2hco,2hnt,2hin,2hue,2h, ,2hus,2he ,2hla, 
     /             2hbe,2hl ,2hco,2hmm,2han,2hd"/ 
cxx lmsg="to continue, use label command"
      data nmsg/32/ 
      data ilen/80/             !  length of ibuf
C 
C     1. First check out the input variables.  Then get the command 
C     into a buffer and find the "=". 
C 
      iclcm = ip(1) 
      do i=1,3
        ip(i) = 0
      enddo
      call char2hol('qn',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
C 
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.ne.0) then
C                   There can be no parameters for this command 
        ip(3) = -200
        return
      endif
C 
C     2. Now form the response message buffer.
C     ***NOTE WE ARE SETTING BOSS'S HALT VARIABLE OURSELVES!!***
C 
      nch = ichmv(ibuf,nchar+1,2h/ ,1,1)
      nch = ichmv(ibuf,nch,lmsg,1,nmsg) - 1 
C 
      khalt = .true.
      call fs_set_khalt(khalt)
      call ifill_ch(ltpnum,1,8,'00') 
      call ifill_ch(ltpchk,1,4,'00') 
C                   Zero out the tape number and check label
C 
C     3. Now send the message back to BOSS. 
C 
      iclass = 0
      call put_buf(iclass,ibuf,-nch,2hfs,0)
      ip(1) = iclass
      ip(2) = 1 
      return
      end 
