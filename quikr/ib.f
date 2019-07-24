      subroutine ib(ip)
C  hpib communications c#870115:04:36# 
C 
C  IB transmits a buffer to HPIB
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS #
C        IP(2) - # RECORDS IN CLASS 
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: CHARACTER ROUTINES
C 
C   LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        NCH    - character counter 
C        IFC     - character index of comma 
      integer*2 ibuf(20)                      !  class buffer
      integer*2 ibuf2(20)                     !  output buffer
      dimension ireg(2)                       !  registers from exec calls
      integer get_buf
      integer*2 iparm(2)                      !  parameters from gtparm
      character cjchar
      equivalence (reg,ireg(1)) 
      equivalence (parm,iparm(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/40/                           !  length of ibuf, characters
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED: CREATED  790309
C 
C     1. Get the class buffer.  Messages for the HPIB consist of
C     the DEVICE followed by data, separated by commas. 
C 
      iclcm = ip(1) 
      ip(1) = 0
      ip(2) = 0                               !  set up return parameters
      call char2hol('qb',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) then
        ip(3) = -1
        return
      endif
      ifc = 1+ieq 
      call gtprm(ibuf,ifc,nchar,0,parm,ierr)  ! scan for mnemonic
      if (cjchar(parm,1).eq.',') then
        ip(3) = -101                          ! no default for mnemonic
        return
      endif
      ibuf2(2) = iparm(1)                 !put mnemonic in 2nd word for ibcon
      if (nchar.lt.ifc) then
        ibuf2(1) = 1                         ! read from device
        nch = 4
      else
        ibuf2(1) = 2                         ! write to device
        nch = nchar - ifc + 1
        idumm1 = ichmv(ibuf2,5,ibuf,ifc,nch)
        nch = nch + 4
      endif
      iclass = 0
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
      if (iclass.eq.0) then 
        ip(3) = -1
        return
      endif
      call run_prog('ibcon','wait',iclass,1,idum,idum,idum)
      call rmpar(ip)
      call devds(ip,iclcm,0)
      return
      end 
