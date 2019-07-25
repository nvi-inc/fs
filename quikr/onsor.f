      subroutine onsor(ip)
C  onsource check c#870115:04:43# 
C 
C     Display on-source information 
C 
C   MODIFIED 850204 TO HANDLE ERROR RETURN FROM ANTCN 
      include '../include/fscom.i'
C 
      dimension ip(1) 
      dimension ireg(2),iparm(2)
      integer get_buf
      integer*2 ibuf(20)
C 
      equivalence (ireg(1),reg),(iparm(1),parm) 
C 
      data ilen/40/ 
C 
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1 
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.ne.0) then
        ierr = -1
        goto 990
      endif
C 
C     2. The command is: ONSOURCE 
C     The response may be either TRACKING or SLEWING, 
C     depending on the variable IONSOR=1 or 0.
C     Schedule ANTCN to get the az,el errors and set IONSOR.
C 
      call fs_get_idevant(idevant)
      if (ichcm_ch(idevant,1,'/dev/null ').ne.0) then
        call run_prog('antcn','wait',3,idum,idum,idum,idum)
        call rmpar(ip)
      else
        ierr= -302
        goto 990
      endif
      ierr = ip(3)
      if (ierr.lt.0)  return
      call fs_get_ionsor(ionsor)
      if (ionsor.eq.0) ierr = -301
C 
      nch = ichmv_ch(ibuf,nchar+1,'/')
C                   Move in the response indicator
      nch = isoed(-1,ionsor,ibuf,nch,ilen)
C                   Encode the response word TRACKING or SLEWING
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qo',ip(4),1,2)
      return
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qo',ip(4),1,2)
      return
      end 
