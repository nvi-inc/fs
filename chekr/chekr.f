      program chekr
C 
C  This program steps through all of the Mark III modules
C  and checks their settings against those sent out by commands
C  or expected values.  All monitor-only values are updated in COMMON. 
C  Those modules specified in the ICHECK array in COMMON are processed.
C 
      include '../include/fscom.i'
C 
C  INPUT: 
C 
C     RMPAR - NOT USED
C 
C  SUBROUTINES CALLED:
C 
C     MATCN - to get data from the modules
C     BOSS  - to report error messages
C     LOGIT - to log and display the error
C     GETVC - decode the MATCN buffers for VC 
C     GETIF - decode the MATCN buffers for IF 
C     GETFM - decode the MATCN buffers for FM 
C     GETTP - decode the MATCN buffers for TP 
C     ERR_REP - report errors from MK3 modules
C     RXCHK - receiver check
C     HDCHK - tape drive check
C 
C  LOCAL VARIABLES: 
      integer get_buf,ichcm_ch
      parameter (iagain=20)      ! repeat period for chekr (seconds)
      parameter (ifastr=2 )      ! repeat period for tape footage
C 
C     IDAREF - reference day number, from HP, re-set every loop 
      integer drive, rack
      dimension ip(5)             ! - for RMPAR
      integer itbuf1(5)
C      - the buffers from MATCN
      integer*2 lmodna(18)
C      - MODule NAmes, 2-char codes
C      - Number of BUFfers for each module
C      - Integer CODES for MATCN for each buffer
      dimension icherr(169),ichecks(21), icheckvs(18)
C      - Arrays for recording identified error conditions
      integer*2 lwho       ! - mnemonic for CHEKR
      integer fc_dad_pid, kpapa
      logical kerr_rep,kall
C
C  INITIALIZED:
C
      data lwho /2Hch/
      data lmodna /2Hv1,2Hv2,2Hv3,2Hv4,2Hv5,2Hv6,2Hv7,2Hv8,2Hv9,2Hva,
     /             2Hvb,2Hvc,2Hvd,2Hve,2Hvf,2Hif,2Hfm,2Htp/
      data nverr,niferr,nfmerr,ntperr /9,8,11,15/
      data ichecks/21*0/
      data icheckvs/18*0/
      data icherr/169*0/
C
C   LAST MODIFIED    LAR  880301      USE HEAD PASS NUMBERS FROM /FSCOM/
C  WHO  WHEN    DESCRIPTION
C  GAG  910204  Changed LFEET to LFEET_FS in call to MA2TP.
C  gag  920729  Added Mark IV code to make sure the strobe character !
C               is not sent to the tape drive.
C  NRV  921030  Added "fastr" to check recorder every 2 seconds, everything
C               else every 20 seconds
C       921208  Changed back to 20 seconds. Need more extensive mods to
C               take care of the side effects of every 2 seconds checking.
C
C  First get our input parameters.
C
      call setup_fscom
      call read_fscom
      call rmpar(ip)
      call fs_get_drive(drive)
      call fs_get_rack(rack)
C
C  Now set up the loop over the to-be-checked modules.
C  Fill up classes with requests to MATCN for data, and
C  send them out.  Do only one module at a time so as not to
C  tie up the communications.  If there is an error in MATCN
C  log it, and go on to the next module.
C
200   continue
      kall = .true.
C
C Get and store reference day number for comparing with formatter
C
      call fc_rte_time(itbuf1,idum)
      idaref = itbuf1(5)
C
      kerr_rep = .false.
      if ((MK3.eq.iand(rack,MK3)).or.(MK4.eq.iand(rack,MK4))) then
        call mk3rack(lmodna,lwho,icherr,ichecks,nverr,niferr,nfmerr,
     .             kall)
        kerr_rep = .true.
      else if (VLBA.eq.iand(rack,VLBA))  then
        call vlbarack(icheckvs,lwho,kall)
      endif
      if ((MK3.eq.iand(drive,MK3)).or.(MK4.eq.iand(drive,MK4))) then
        call mk3drive(lwho,lmodna,nverr,niferr,nfmerr,ntperr,icherr,
     .                ichecks,kall)
        kerr_rep = .true.
      else if (VLBA.eq.iand(drive,VLBA)) then
        call vlbadrive(icheckvs,lwho,kall)
      endif
C
C  This is the error-reporting section.  The array ICHERR is
C  examined to determine which error messages, if any, should
C  be logged and displayed.
C
      if (kerr_rep) then
        call err_rep(lmodna,lwho,icherr,ichecks,nverr,niferr,nfmerr,
     .               ntperr)
      endif
C
C  Now we're going to check out the receiver.
C
800    continue
       if (.not.kall) goto 1000
       call fs_get_icheck(icheck(19),19)
       if(icheck(19).le.0.or.ichecks(19).ne.icheck(19)) goto 900
       call rxchk(ichecks,lwho)
C
C 9. Check tape head positioning.
C
900   continue
       call fs_get_icheck(icheck(20),20)
       if (icheck(20).le.0.or.ichecks(20).ne.icheck(20)) goto 910
       call hdchk(ichecks,lwho)
C
910    continue
       if((MK3.eq.iand(MK3,rack)).or.(MK4.eq.iand(MK4,rack))) then
         call fs_get_icheck(icheck(21),21)
         if (icheck(21).le.0.or.ichecks(21).ne.icheck(21)) goto 1000
         call i3chk(ichecks,lwho)
       endif
C
C 10. Once we are finished, take a breather for 20 seconds.
C
1000  continue
      do i=1,21
        call fs_get_icheck(icheck(i),i)
        ichecks(i)=icheck(i)
      enddo
      do i=1,18
        call fs_get_ichvlba(ichvlba(i),i)
        icheckvs(i)=ichvlba(i)
      enddo
      call fs_get_stcnm(stcnm(1,1),1)
      if(ichcm_ch(stcnm(1,1),1,'  ').ne.0) then
         ip(1)=0
         if(kpapa) then
           ip(2)=1
         else
           ip(2)=0
         endif
         call run_prog('cheks','wait',ip(1),ip(2),ip(3),ip(4),ip(5))
      endif
      call wait_relt('chekr',ip,2,iagain)
      kall=.true.
C     icount=icount+1
C     kall=.false.
C     if (icount.eq.10) then ! do the whole thing every 10th time
C       icount=0
C       kall=.true.
C     endif
      call read_quikr
      kpapa=fc_dad_pid().ne.0
      if (kpapa) then
        do i=1,21
          call fs_get_icheck(icheck(i),i)
          ichecks(i)=icheck(i)
        enddo
        do i=1,18
          call fs_get_ichvlba(ichvlba(i),i)
          icheckvs(i)=ichvlba(i)
        enddo
      endif
      goto 200
C
      end
