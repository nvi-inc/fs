      subroutine lgout(ip)
C  output log lus c#870115:04:53# 
C 
C     LGOUT specifies output LUs for log entries
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
      dimension ilu(5)                !  temp holder for specified lus
C     NLU - temp holder for # of LUs
C        NCHAR  - number of characters in buffer
C        NCH    - character counter 
      integer*2 ibuf(20)                !  class buffers
      dimension ireg(2)                !  registers from exec calls
      integer get_buf
      dimension iparm(2)               !  parameters from gtparm
      character cjchar
      equivalence (reg,ireg(1)) 
      equivalence (parm,iparm(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/40/                           !  length of ibuf, chars
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED: CREATED  820323
C 
C 
C     1. Get the class buffer.  Messages for the LGOUT consist of 
C     a series of LUs, separated by commas. 
C 
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0.or.cjchar(ibuf,ieq+1).eq.'?') goto 500  
C 
C     2. Scan input command for specified LUs.
C 
      ich = ieq+1 
      nlu = 0 
201   continue
      ich1=ich
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
C                   Scan for a number, the LU 
      if (ierr.ne.0) then
        ierr = -201
        goto 990
      endif
      if (cjchar(parm,1).eq.',') then
        if (nlu.gt.0) goto 300
        call char2hol('/dev/tty',idevlog(1,1),1,64)
        nlu = 1
      else if (iparm(1).lt.0) then
        ierr = -202
        goto 990
      else if (nlu.ge.5) then
        ierr = -203
        goto 990
      else
        nlu = nlu+1
        icm = iscn_ch(ibuf,ich1,nchar,',')
        if(icm.eq.0) then
          icm=nchar
        else
          icm=icm-1
        endif
        n=min(64,icm-ich1+1)
        idum=ichmv(idevlog(1,nlu),1,ibuf,ic1,n)
        call char2hol(' ',idevlog(1,nlu),n+1,64)
      endif
      goto 201
C 
C     3. Stash LUs into common for DDOUT. 
C 
300   continue
      call fs_set_idevlog(idevlog)
      call fs_set_ndevlog(ndevlog)
      ierr = 0
      goto 990
C 
C     5. Display current list of LUs. 
C 
500   if (ieq.eq.0) ieq=nchar+1 
      nch = ichmv(ibuf,ieq,2h/ ,1,1)
C                   Put / to indicate a response
      call fs_get_ndevlog(ndevlog)
      call fs_get_idevlog(idevlog)
      do i=1,ndevlog
        if (i.ne.1) nch = mcoma(ibuf,nch)
        ilc=iflch(idevlog(1,i),64)
        nch=ichmv(ibuf,nch,idevlog(1,i),1,ilc)
      enddo
      nch = nch-1
C 
      iclass = 0
      call put_buf(iclass,ibuf,-nch,2hfs,0)
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('q#',ip(4),1,2)
      return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('q#',ip(4),1,2)
      return
      end 
