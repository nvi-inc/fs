      subroutine upset(ip)
C  upconverter setup 
C  This is a copy of LO and LODIS
C 
C     UPSET sets up the common array FREQUP 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C   COMMON BLOCKS USED
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: GTPRM
C 
C   LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      real frhld(4)
C               - temporary holder for decoded frequencies 
C        INUM   - number of freqs input
      integer*2 ibuf(20)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC calls 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 
C  INITIALIZED VARIABLES
      data ilen/40/ 
C 
C  PROGRAMMER: NRV & MAH
C     CREATED: 820310 
C     Modify for PC 920226
C 
C 
C     1. If we have a class buffer, then we are to set the
C     variables in common for PCALR to use. 
C 
      ichold = -99
      iclcm = ip(1) 
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 120
      if (ieq.eq.nchar) goto 500
C                   If no parameters, this is an error. 
      if (cjchar(ibuf,ieq+1).ne.'?') goto 210
      ip(1) = 0 
      ip(4) = o'77' 
120   call updis(ip,iclcm)
      return
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C     Mark III:   UPCONV=<up1nor>,<up2nor>,<up3>,<up1alt>,<up2alt> 
C     VLBA:       UPCONV=<upA>,<upB>,<upC>,<upD>
C     Upconverter freq in MHz, no default
C                          same for all parameters
C 
C     2.1  ALL PARMS DECODED IN LOOP
C 
210   continue
      call fs_get_rack(rack)
      ich = ieq+1 
      inum = 0
      do i = 1,4
        frhld(i) = 0
        call gtprm(ibuf,ich,nchar,2,parm,ierr)
        if (cjchar(parm,1).ne.',') then
          if (ierr.ne.0) then
            ierr = -200-i 
            goto 990
          endif
          frhld(i) = parm 
          inum = inum+1 
        endif
      enddo
      if (inum.eq.0) goto 500 
C             error if no input after "=" 
C 
C     Set up the common array now 
C 
400   call fs_set_frequp(frhld(1),0)
      call fs_set_frequp(frhld(2),1)
      call fs_set_frequp(frhld(3),2)
      call fs_set_frequp(frhld(4),3)
      goto 990
500   continue
      ierr = -101 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('q*',ip(4),1,2)
      return
      end 
