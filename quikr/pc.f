      subroutine pc(ip)
C  send message to ibm pc c#870115:04:57#
C 
C  INPUT VARIABLES: 
C 
      dimension ip(1) 
C         IP(1) - Class number of input parameter buffer
C 
C  OUTPUT VARIABLES:
C 
C         IP(3) - Error 
C         IP(4) - who we are
C 
C  COMMON BLOCKS USED:
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
C  LOCAL VARIABLES: 
C 
      integer it(6)
      double precision daz,del
      integer*2 ibuf(42)
      dimension ireg(2),iparm(2)
      integer get_buf,ichcm_ch
C 
      equivalence (reg,ireg(1)) 
      equivalence (parm,iparm(1))
C 
C  INITIALIZED VARIABLES: 
C 
      data ilen /84/  
C 
C  HISTORY: 
C 
C  DATE  WHO  WHAT
C 841126 MWH  CREATED 
C 
C 
C  1. Get the input class buffer
C 
      iclcm = ip(1) 
      if (iclcm.ne.0) goto 110
        ierr = -1 
        goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.ne.0) goto 120
        ierr = -2 
        goto 990
120   icom = iscn_ch(ibuf,ieq,nchar,',')
130   if (nchar.gt.icom) goto 140 
        ierr = -4 
        goto 990
140   iecho = 0 
      call fs_get_kecho(kecho)
      if (kecho) iecho = 1
C 
C  2.  Parse input string and put message into class
C 
200   nch = ieq + 1
      call gtprm(ibuf,nch,nchar,0,parm,ierr)
      if(ichcm_ch(iparm,1,'init').ne.0) goto 210
        imode = 0
        goto 300
210   if(ichcm_ch(iparm,1,'nres').ne.0) goto 220
        imode = 1
        goto 240
220   if(ichcm_ch(iparm,1,'resp').ne.0) goto 230
        imode = 2
        goto 240
230     ierr = -5
        goto 990
240   call gtprm(ibuf,nch,nchar,0,parm,ierr)
      icom = nch - 1
      if(ichcm_ch(iparm,1,'frm').eq.0) goto 250
C  Shift mesage to beginning of buffer and put into class 
      nchar = nchar - icom
      idumm1 = ichmv(ibuf,1,ibuf,icom+1,nchar)
      goto 300
C  Handle MET or LOS commands 
250   continue
      if (ichcm_ch(ibuf,icom+1,'met').eq.0) goto 260 
      ityp = 0
      if (ichcm_ch(ibuf,icom+1,'los').eq.0) ityp = 1 
      if (ichcm_ch(ibuf,icom+1,'point').eq.0) ityp = 2 
      if(ityp.gt.0) goto 270
        ierr = -3
        goto 990
C  Handle MET here
260   nch = ichmv(ibuf,1,4hmet=,1,4)
      call fs_get_tempwx(tempwx)
      call fs_get_preswx(preswx)
      call fs_get_humiwx(humiwx)
      nch = nch + ir2as(tempwx,ibuf,nch,5,1)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(preswx,ibuf,nch,7,1)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(humiwx,ibuf,nch,5,1)
      nchar = nch - 1 
      goto 300
C  Handle LOS here
270   continue
      call fc_rte_time(it,it(6))
      call fs_get_radat(radat)
      call fs_get_decdat(decdat)
      call fs_get_alat(alat)
      call fs_get_wlong(wlong)
      call cnvrt(1,radat,decdat,daz,del,it,alat,wlong)
      az = daz*180./RPI 
      el = del*180./RPI 
      if(iscn_ch(ibuf,icom,nchar,'=').ne.0) el = 90.0
      if (az.ge.0..and.az.le.360.) goto 275 
        ierr = -7 
        goto 990
275   if (el.ge.0..and.el.le.180.) goto 280 
        ierr = -8 
        goto 990
280   if(ityp.eq.1) nch = ichmv(ibuf,1,4hlos=,1,4)
      if(ityp.eq.2) nch = ichmv(ibuf,1,6hpoint=,1,6)
      nch = nch + ir2as(az,ibuf,nch,5,1)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(el,ibuf,nch,5,1)
      if(ityp.eq.1) nch = ichmv(ibuf,nch,5h,,,,g,1,5)
      if(ityp.eq.2) nch = ichmv(ibuf,nch,3h,,g,1,3)
      nchar = nch - 1 
C 
C  3.  RP and schedule PCCOM
C 
300   iclass = 0
      if (imode.ne.0) call put_buf(iclass,ibuf,-nchar,2hfs,0) 
cxx      if (ipgst(6hpccom ).ne.-1) goto 320 
cxx        if (irp(6hpccom ,0,ierr,0).ge.0) goto 320 
cxx          ierr = -6 
cxx          goto 990
320   write(6,8888)
8888  format(10x,"time to run PCCOM from PC",/)
cxx320   call run_prog('pccom','nowait',lu,0,imode,iclass,iecho)  
      ip(1) = iclass
C 
C  9.  That's all there is
C 
900   ierr = 0
      goto 995
990   ip(1) = 0 
995   ip(2) = 0 
      ip(3) = ierr
      call char2hol('q:',ip(4),1,2)
      return
      end 
