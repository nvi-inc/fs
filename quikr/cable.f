      subroutine cable(ip, itask)
C  measure cable cal c#870115:04:36#
C 
C   CABLE gets the cable cal value
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - error
C        IP(2) - class
C        IP(3) - number of records
C        IP(4) - who we are 
C 
C   COMMON BLOCKS USED
C 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: GTPRM
C 
C   LOCAL VARIABLES 
C 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(20),ibuf2(10)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC calls 
C 
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C   INITIALIZED VARIABLES 
C 
      data ilen/40/,ilen2/20/ 
C 
C   PROGRAMMER: NRV 
C     LAST MODIFIED:  810207
C 
C 
C     1. Introduction.  Get command class, find "=" if any. 
C 
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C                   If no parameters, go read device
C 
C 
C     2. Simply move the requested data into the output buffer. 
C 
      ibuf2(1) = +2 
C                   Writing data, using mnemonic
      call char2hol('ca',ibuf2(2),1,2)
      nc = min0(ilen2-4,nchar-ieq)
      if (nc.gt.0) nch = ichmv(ibuf2,5,ibuf,ieq+1,nc)-1 
      iclass=0
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
      nrec = 1
      goto 800
C 
C 
C     5.  This is the read device section.
C 
500   ibuf2(1) = 1
      call char2hol('ca',ibuf2(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf2,-4,'fs','  ')
      nrec = 1
      goto 800
C 
C 
C     8. All IBCON requests are scheduled here, and then CADIS called.
C 
800   call run_prog('ibcon','wait',iclass,nrec,idum,idum,idum)
      call rmpar(ip)
      call cadis(ip,iclcm, itask)
      return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qy',ip(4),1,2)

      return
      end 
