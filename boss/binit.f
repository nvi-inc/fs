      subroutine binit(ip,lnames,nnames,itscb,ntscb,idcbsk,ierr)
C                INITIALIZE BOSS          <910322.1647>
C
C  HISTORY:
C    WHO  WHEN    WHAT
C    NRV  801201  modified
C    NRV  810730  Add error calls to LOGIT in new format
C    MWH  850121  Call RMPAR on return from ANTCN
C    WEH  850501  Print a message if we didn't initialize ANCTN
C    LAR  880105  Change LNAMES to contain names instead of hash codes
C    gag  920713  changed hex index from 1 to 3 to 1 to 7
C
      include '../include/fscom.i'
      include 'bosscm.i'
C
      integer*4 ip(5)                   !  rmpar values from boss
      integer idcbsk(1)                 !  dcss for schedule
      dimension lnames(12,1)            !  list of command names
      integer itscb(13,1)               !  time-scheduling control block
      integer ibuf(50)                  !  input buffer containing command
      integer itime(9)                  !  time array returned from spars
      integer lseg(2)                   !  segment name (obsolete)
      integer it(5)
      integer ieqhex(7)
      data ieqhex /z'01',z'02',z'03',z'04',z'05',z'06',z'07'/
C
C
C     1. First initialize values from RMPAR parameters.
C     IP(1) = LU for terminal input and messages
C     IP(2) = LU for logs and procedures (optional)
C
      call fs_get_iclopr(iclopr)
      call fs_get_iclbox(iclbox)
      lu = ip(1)
      if (lu.eq.0) lu = 6
      icrlog = ip(2)
C
      call fc_rte_time(itime,idum)
      itoday = itime(5)
C
      do  i=1,ntscb
        itscb(1,i) = -1
      enddo
C
      call fc_putln('station config init')
C
C
C     1.1 READ IN ALLOWED COMMAND NAMES
C
      iname = 0
      call fmpopen(idcbsk,FS_ROOT//'/control/stcmd.ctl',ierr,'r',id)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-110,2hbo,ierr)
        return
      endif
      ierr = 0
      ilen = 0
      call readg(idcbsk,ierr,ibuf,ilen)
      do while (ilen.ne.-1)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-111,2hbo,ierr)
          return
        endif
        if (ilen.gt.0) then
          iname = iname + 1
          if (iname.gt.nnames) then
            call logit7(0,0,0,1,-112,2hbo,nnames)
            return
          endif
          idummy = ichmv(lseg,1,ibuf,14,4)
          iss = ias2b(ibuf,18,4)
          ity = ias2b(ibuf,23,2)
          ieq1 = ias2b(ibuf,26,1)
          ieq2 = ias2b(ibuf,27,1)
          call ichmv(lnames(1,iname),1,ibuf,1,12)
          lnames(7,iname) = lseg(1)
          lnames(8,iname) = lseg(2)
          lnames(9,iname) = iss
          lnames(10,iname) = ity
          if ((ieq1.ge.1) .and. (ieq1.le.7)) then
            lnames(11,iname) = ieqhex(ieq1)
          else
            lnames(11,iname) = 0
          endif
          if ((ieq2.ge.1) .and. (ieq2.le.7)) then
            lnames(12,iname) = ieqhex(ieq2)
          else
            lnames(12,iname) = 0
          endif
        endif
        call readg(idcbsk,ierr,ibuf,ilen)
      enddo
      call fmpclose(idcbsk,ierr)
      call fmpopen(idcbsk,FS_ROOT//'/fs/control/fscmd.ctl',ierr,'r',id)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-110,2hbo,ierr)
        return
      endif
      ierr = 0
      ilen = 0
      call readg(idcbsk,ierr,ibuf,ilen)
      do while (ilen.ne.-1)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-111,2hbo,ierr)
          return
        endif
        if (ilen.gt.0) then
          iname = iname + 1
          if (iname.gt.nnames) then
            call logit7(0,0,0,1,-112,2hbo,nnames)
            return
          endif
          idummy = ichmv(lseg,1,ibuf,14,4)
          iss = ias2b(ibuf,18,4)
          ity = ias2b(ibuf,23,2)
          ieq1 = ias2b(ibuf,26,1)
          ieq2 = ias2b(ibuf,27,1)
          call ichmv(lnames(1,iname),1,ibuf,1,12)
          lnames(7,iname) = lseg(1)
          lnames(8,iname) = lseg(2)
          lnames(9,iname) = iss
          lnames(10,iname) = ity
          if ((ieq1.ge.1) .and. (ieq1.le.7)) then
            lnames(11,iname) = ieqhex(ieq1)
          else
            lnames(11,iname) = 0
          endif
          if ((ieq2.ge.1) .and. (ieq2.le.7)) then
            lnames(12,iname) = ieqhex(ieq2)
          else
            lnames(12,iname) = 0
          endif
        endif
        call readg(idcbsk,ierr,ibuf,ilen)
      enddo
      call fmpclose(idcbsk,ierr)
      nnames = iname
      call fc_putln('command list init')
C
C
C     1.15 Initialize MATCN's names and addresses.
C
      call rdtma(idcbsk,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-114,2hbo,ierr)
c       return
        call fc_putln('matcn initialization failed')
      else
        call fc_putln('matcn initialized')
      endif
C
C
C     1.16 Initialize tables in IBCON
C
      call rdtib(idcbsk,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-115,2hbo,ierr)
c       return
        call fc_putln('ibcon initialization failed')
      else
        call fc_putln('ibcon initialized')
      endif
C
C     1.17 Initialize the antenna interface, if any.
C
      ierr = 0
      call fs_get_idevant(idevant)
      if (ichcm_ch(idevant,1,'/dev/null ').ne.0) then
C                   For testing with LUANT=LU, don't issue CNs
        call run_prog('antcn','wait',ip(1),ip(2),ip(3),ip(4),ip(5))
        call rmpar(ip)
        ierr = ip(3)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-116,2hbo,ierr)
c         return
          call fc_putln('antenna initialization failed')
        else
          call fc_putln('antenna initialized')
        endif
      else
        call fc_putln('antenna not initialized!!')
      endif
c
c  initialize mcbcn
c
      ip(1)=0
      call run_prog('mcbcn','wait',ip(1),ip(2),ip(3),ip(4),ip(5))
      ierr=ip(3)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-117,2hbo,ierr)
c       return
        call fc_putln('mcbcn initialization failed')
      else
        call fc_putln('mcbcn initialized')
      endif
C
C     1.18 Start first log file
C
      call char2hol('station ',illog,1,8)
      call fs_set_llog(illog)
      call fc_rte_time(it,iyear)
      call newlg(ibuf,2h::)
    
      call put_buf(iclopr,29H"Boss Initialization Complete, -29,0,0)
      call put_buf(iclopr,8Hiniti   , -5,0,0)
C
      return
      end
