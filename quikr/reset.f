      subroutine reset(ip)
C  mat reset        <900517.1618>
C 
C 1.1.   RESET resets the MAT interface 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # RECORDS
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: GTPRM,IFILL 
C 
C 3.  LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(20)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC calls 
      dimension irate(7),irind(7) 
C               - baud rate selections, and DVB00 indices corresponding 
C     IB - selected baud rate, in bits
C     IBIND - selected baud rate, DVB00 index 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/40/ 
      data nrates/7/
      data irate/110,300,600,1200,2400,4800,9600/ 
      data irind/3,6,0,7,9,10,11/
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:  800316
C 
C     PROGRAM STRUCTURE 
C 
C     1. If we have a class buffer, then we are to set the baud rate. 
C     If no class buffer, this is an error. 
C 
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) then
        ierr = -1
        goto 990
      endif
C                   If no parameters, ERROR 
      if (ieq.ne.nchar.and.cjchar(ibuf,ieq+1).eq.'?') goto 500 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has the form:   RESET=<baud>
C 
      ich = 1+ieq
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_ibmat(ibmat)
        ib = ibmat
      else if (cjchar(parm,1).eq.',') then
        ib = 2400       ! default is 2400 baud
      else
        do i=1,nrates         ! check for legal speed request
          if (iparm(1).eq.irate(i)) then
            ib = irate(i)
            ibind = irind(i)
            goto 300
          endif
        enddo
        ierr = -201
        goto 990
      endif
C 
C     3. These values have been planted in COMMON.  Reset MAT interface.
C 
300   continue
      ibmat=ib
      call fs_set_ibmat(ibmat)
C                   Change baud rate to our requested value 
      iclass = 0
      ibuf(1) = 55 
      call ifill_ch(ibuf(2),1,38,'U') 
C                   Fill up the buffer with UUUUUUUUUUU's 
C                   Send string of U's to synch up
      call put_buf(iclass,ibuf,-40,2hfs,0)
      call run_matcn(iclass,1) 
      call rmpar(ip)
      return
C 
C     5. Return current baud rate setting.
C 
500   nch = ichmv(ibuf,ieq,2h/ ,1,1)
      call fs_get_ibmat(ibmat)
      nch = nch + ib2as(ibmat,ibuf,nch,o'100000'+4) -1
      iclass = 0
      call put_buf(iclass,ibuf,-nch,2hfs,0)
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qm',ip(4),1,2)
      return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      ip(5)=0
      call char2hol('qm',ip(4),1,2)
      return
      end
