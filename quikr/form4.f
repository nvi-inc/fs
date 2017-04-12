      subroutine form4(ip,itask)
C  Mark IV formatter command 
C 
C  form4 transmits a buffer to MATCN 
C 
C   INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C    COMMON BLOCKS USED 
C 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: CHARACTER ROUTINES
C 
C   LOCAL VARIABLES 
C 
C        NCHAR  - number of characters in buffer
C        NCH    - character counter 
      integer*2 ibuf(50),ibuf2(50) 
C               - class buffer
C               - output buffer for transmission
C        ILEN   - length of IBUF, chars 
      dimension ireg(2) 
      integer get_buf
C 
C    INITIALIZED VARIABLES
C 
      data ilen/100/
C 
C  HISTORY:  
C  WHO  WHEN    WHAT
C  gag  920715  Created.
C 
C     1. Get the class buffer.
C
      ierr = 0
      iclcm = ip(1)
      if (iclcm.ne.0) goto 110
100   ierr = -1
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if ((ieq.eq.0).or.(ieq.eq.nchar)) goto 100
C                   If no parameters, get mad!
      nrec = 0
      iclass = 0
      ifc = 1+ieq
      if(itask.eq.2) then
         call upper(ibuf,1,nchar)
      endif
      nch = nchar - ifc + 1
      call pchar(idum,2,9)
      nenq = iscnc(ibuf,ifc,nchar,9)
C                   Scan for a tab character
      if (nenq.ne.0) idumm1 = ichmv(ibuf,nenq,o'5',2,1)
C                   If we found one, substitute the enq character
      if(itask.eq.2) then
         ibuf2(1) = 9
C                   Set up for MAT mode 9
         idumm1 = ichmv_ch(ibuf2(2),1,'fm')
C                   Place fm mnemonics in buffer.
      else if(itask.eq.3) then
         ibuf2(1) = 10
C                   Set up for MAT mode 10
         idumm1 = ichmv_ch(ibuf2(2),1,'de')
C                   Place de mnemonics in buffer.
      endif
      idumm1 = ichmv(ibuf2(3),1,ibuf,ifc,nch)
C                   Move characters to output buffer starting at first
C                   character of this message.
      nch = nch + 4
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
      nrec = nrec + 1
C
      ierr = 0
      if (iclass.ne.0) goto 980
      ierr = -1
      goto 990
980   call run_matcn(iclass,nrec)
      call rmpar(ip)
      call devds(ip,iclcm,1)
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qb',ip(4),1,2)
      return
      end 
