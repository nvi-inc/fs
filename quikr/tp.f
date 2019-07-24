      subroutine tp(ip)
C  parse tape command
C 
C  TP controls the tape controller
C 
C     INPUT VARIABLES:
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
C   COMMON BLOCKS USED
C 
      include '../include/fscom.i'
C 
C 
C     CALLING SUBROUTINES:
C 
C     CALLED SUBROUTINES: GTPRM
C 
C   LOCAL VARIABLES 
C 
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
C        ISP,IDIR,ILOW
C               - indices for speed, direction, lowtape 
C 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C   INITIALIZED VARIABLES 
C 
      data ilen/40/ 
C 
C  PROGRAMMER: NRV
C     LAST MODIFIED:  810207
C 
C 
C     1. If we have a class buffer, then we are to set the TP.
C     If no class buffer, we have been requested to read the TP.
C 
      ichold = -99
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C                   If no parameters, go read device
      if (cjchar(ibuf,ieq+1).eq.'?') then
        ip(1) = 0
        ip(4) = o'77'
        call tpdis(ip,iclcm)
        return
      endif
C 
      if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700 
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C                   TAPE=<lowtape>,<reset>
C                 <lowtape>: ON or OFF.  Default ON.
C                 <footage>: RESET or <blank>.  Default <blank>.
C 
C     2.1 LOW TAPE, PARAMETER 1 
C 
      ich = 1 + ieq
      ic1 = ich 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(iparm,1).eq.'*') then
        ilow = ilowtp
      else if (cjchar(iparm,1).eq.',') then
        ilow = 1         ! default value is "on"
      else
        call itped(3,ilow,ibuf,ic1,ich-2)
        if (ilow.lt.0) then
          ierr = -201
          goto 990
        endif
      endif
C 
C 
C     2.2 FOOTAGE COUNTER RESET, PARAMETER 2
C 
      ic1 = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(iparm,1).eq.'*') then
        irst = irsttp
      else if (cjchar(iparm,1).eq.',') then
        irst = 0         !  default value is leave alone
      else
        call itped(4,irst,ibuf,ic1,ich-2)
        if (irst.lt.0) then
          ierr = -202
          goto 990
        endif
      endif
C 
C 
C     3. Now plant these values into COMMON.
C 
      call fs_get_icheck(icheck(18),18)
      ichold = icheck(18)
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      ilowtp = ilow 
      irsttp = irst 
C 
C 
C     4. Set up buffer for tape drive.  Send to MATCN.
C     First message sets up low tape sensor and footage counter:
C                   TP(l0f00000 
C 
      ibuf(1) = 0 
      call char2hol('tp',ibuf(2),1,2)
      call tp2ma(ibuf(3),ilow,irst) 
C 
      iclass = 0
      call put_buf(iclass,ibuf,-13,2hfs,0)
C 
      nrec = 1
      goto 800
C 
C 
C     5.  This is the read device section.
C     Fill up two class buffers,
C     one  requesting ( (mode -3), one ! (mode -1). 
C 
500   call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      nrec = 0
      ibuf(1) = -3
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = nrec + 1
      call fs_get_drive(drive)
      if (MK3.eq.iand(MK3,drive)) then
        ibuf(1) = -1
        call put_buf(iclass,ibuf,-4,2hfs,0)
        nrec = nrec + 1
      endif
C 
      goto 800
C 
C 
C     6. This is the test/reset device section. 
C 
600   ibuf(1) = 6 
      call char2hol('tp',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C 
C 
C     7. This is the alarm query and reset request. 
C 
700   ibuf(1) = 7 
      call char2hol('tp',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      goto 800
C 
C 
C     8. All MATCN requests are scheduled here, and then TPDIS called.
C 
800   call run_matcn(iclass,nrec)
      call rmpar(ip)
      if (ichold.ne.-99) then
        icheck(18) = ichold  
        call fs_set_icheck(icheck(18),18)
      endif
      if (ichold.ge.0) then
        icheck(18) = 1 
        call fs_set_icheck(icheck(18),18)
      endif
      call tpdis(ip,iclcm)
      return
C 
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qt',ip(4),1,2)
      return
      end 
