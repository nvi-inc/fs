      subroutine patch(ip)
C 
C     PATCH sets up the common array IFP2VC 
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
      dimension ifp(14) 
C               - temporary holder for decoded Patching.
C        ICHNL  - channel number
C        IVC    - VC number 
C        IVL    - -1 for Lo, +1 for High
      integer*2 ibuf(40)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls 
C 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C  INITIALIZED VARIABLES
      data ilen/80/ 
C 
C  PROGRAMMER: NRV & MAH
C     CREATED: 820310 
C 
C 
C     1. If we have a class buffer, then we are to set the
C     variables in common for PCALR to use. 
C 
      iclcm = ip(1) 
      do i=1,3
        ip(i) = 0
      enddo
      call char2hol('qq',ip(4),1,2)
      ichold = -99
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) then
        call padis(ip,iclcm)
        return
      endif
      if (ieq.eq.nchar) then
        ip(3) = -101
        return
      endif
      if (cjchar(ibuf,ieq+1).eq.'?') then
        ip(1) = 0
        ip(4) = o'77'
        call padis(ip,iclcm)
        return
      endif
C
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters:
C        PATCH=<LO#>,<VC#H(or L)>,<VC#H(or L)>,.........
C     Choices are <LO#>: LO1, LO2, or LO3, no default
C                 <VC#H(or L)>  : no default, must be at least one
C
C     2.1 FIRST PARM, LO NUMBER
C
      ich = 1+ieq
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.',' .or. ichcm_ch(parm,1,'lo').ne.0) then
        ip(3) = -201
      else
        ichnl = ias2b(parm,3,1)
        if (ichnl.lt.1 .or. ichnl.gt.3) ip(3)= -201
      endif
      if (ip(3).eq.-201) return
C 
C     2.2  2nd and subsequent parms, VC#, H or L. 
C 
      ifc = 0
      call fs_get_ifp2vc(ifp2vc)
      do i=1,14 
        ifp(i) = ifp2vc(i)
      enddo
C
C  Loop through until end of input, then exit.
C
300   call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.',') then
        if (ifc.le.0) then
          ip(3) = -102
        else                          !  set up the common array now
          do i=1,14
            ifp2vc(i) = ifp(i)
          enddo
        endif
        call fs_set_ifp2vc(ifp2vc)
        return
      endif
      nch = 2 
      if (cjchar(parm,3).eq.' ') nch = 1 
      ivc = ias2b(parm,1,nch) 
      if (ivc.lt.1 .or. ivc.gt.14) ip(3)= -202
      if (cjchar(parm,nch+1).ne.'h' .and.cjchar(parm,nch+1).ne.'l')
     :    ip(3) = -203
      if (ip(3).lt.0) return
      ivl = 1
      if (cjchar(parm,nch+1).eq.'l') ivl = -1 
      ifp(ivc) = ivl*ichnl
      ifc = ifc+1 
      goto 300
C
      end 
