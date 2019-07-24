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
C decalration for class buffer
C
      integer iadd,bits,stop,parity
      integer*2 idev(33),iwora
      integer*4 iclass,baud
      common/lgoutcm/iclass,baud,iadd,bits,stop,parity,idev,iwora
C
C valid baud rates table
C
      integer MAX_RATES
      parameter (MAX_RATES=15)
      integer*4 rates(MAX_RATES)
      data rates/50,75,110,134,150,200,300,600,1200,1800,2400,4800,
     &           9600,19200,38400/
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/40/                           !  length of ibuf, chars
C 
C 6.  LAST MODIFIED: CREATED  820323
C 
C 
C     1. Get the class buffer. 
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
C     2. Scan input command
C 
      ich = ieq+1 
      iadd=0
      baud=0
      iwora=0
      ich1=ich
      call gtprm2(ibuf,ich,nchar,0,parm,ierr)
C                   Scan for a "*", which tells us to add new output
      if (ierr.lt.0) then
        ierr = -301
        goto 990
      else if (ierr.eq.1) then !*
        call fs_get_ndevlog(ndevlog)
        if (ndevlog.ge.5) then
          ierr = -302
          goto 990
        endif
        iadd=1
        ich1=ich
      endif
c
c  get device name
c
      ich=ich1
      call gtprm2(ibuf,ich,nchar,0,parm,ierr)
      if(ierr.eq.2) then
         call pchar(idev,1,0)
      else
        icm = iscn_ch(ibuf,ich1,nchar,',')
        if(icm.eq.0) then
          icm=nchar
        else
          icm=icm-1
        endif
        n=min(64,icm-ich1+1)
        idum=ichmv(idev,1,ibuf,ich1,n)
        call pchar(idev,idum,0)
      endif
c
c  is there more information?
c
      ich1=ich
      call gtprm2(ibuf,ich,nchar,0,parm,ierr)
      if(ierr.eq.2.or.ichcm_ch(parm,1,'w ').eq.0) then
         call char2hol('w'//char(0),iwora,1,2)
         goto 300
      else if(ichcm_ch(parm,1,'a ').eq.0) then
         call char2hol('a'//char(0),iwora,1,2)
         goto 300
      else
        call gtprm2(ibuf,ich1,nchar,1,parm,ierr)
        if(ierr.eq.0) Then
          do i=1,MAX_RATES
            if(iparm(1).eq.rates(i)) then
              goto 205
            endif
          enddo
        endif
        ierr=-202
        goto 990
      endif
205   continue
      baud=iparm(1)
c
c  okay we have a line protocal, get the remaining info
C
C  bits
c
      call gtprm2(ibuf,ich1,nchar,1,parm,ierr)
      bits=0
      if(ierr.eq.2) then
        bits=8
      else if(ierr.eq.0) then
        bits=iparm(1)
      endif
      if(ierr.lt.0.or.bits.lt.5.or.bits.gt.8) then
        ierr=-203
        goto 990
      endif
c
c  parity
c
      call gtprm2(ibuf,ich1,nchar,0,parm,ierr)
      parity=-1
      if(ierr.eq.2) then
        parity=0
      else if(ierr.eq.0) then
        if(ichcm_ch(parm,1,'e').eq.0) then
          parity=2
        else if(ichcm_ch(parm,1,'o').eq.0) then
          parity=1
        else if(ichcm_ch(parm,1,'n').eq.0) then
          parity=0
        endif
      endif
      if(ierr.lt.0.or.parity.gt.2.or.parity.lt.0) then
        ierr=-204
        goto 990
      endif
C
C stop bits
c
      call gtprm2(ibuf,ich1,nchar,1,parm,ierr)
      stop=-1
      if(ierr.eq.2) then
        stop=1
      else if(ierr.eq.0) then
        stop=iparm(1)
      endif
      if(ierr.lt.0.or.stop.lt.1.or.stop.gt.2) then
        ierr=-205
        goto 990
      endif
C 
C     3. Send logging request to DDOUT. 
C 
300   continue
      call fc_cls_alc(iclass)
      call fs_get_iclbox(iclbox)
      call put_buf(iclbox,iclass,-92,2Hfs,2Hlo)
      idum = get_buf(iclass,ip,-20,idum,idum)
      ierr = 0
      if(ip(3).ne.0) then
        ierr=-400-ip(3)
      endif
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
