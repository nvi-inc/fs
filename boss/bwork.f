*
* Copyright (c) 2020, 2023, 2025 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine bwork(ip,lnames,nnames,lproc1,maxpr1,lproc2,maxpr2,
     .itscb,ntscb,idcbsk)
C
C     This is the working subroutine of the Field System BOSS program.
C
C     DATE   WHO CHANGES
C     810906 NRV Added procedure lists, 12-char proc names.
C     840217 MWH Modified procedure stack structure.
C     840320 MWH Added LIST and STATUS SNAP commands.
C     880427 LAR "PROC=" changes schedule, not station, procedure library
C     880428 LAR Allow for STQKR calls in QUIKR processing section
C     910104 GAG Added RNRQ call before changing procedure file with
C                PROC= command.
C     910205 GAG Removed calls to QUIK1 and QUIK2 and added call to
C                QUIKR.
C     920910 gag Increased the constant in the min0 call parameter of
C                logit4 call for the TI, time list, command print out.
C     920922 gag Consolidated quikr routines back into one program.
C
      include '../include/fscom.i'
      include '../include/boz.i'
C
      integer*4 ip(5),ipinsnp(5)        !  array for rmpar parameters
      dimension iparm(2)                      ! parameters from gtprm
      equivalence (parm,iparm(1))
      dimension lnames(13,1)
      integer*4 lproc1(4,1),lproc2(4,1)
C                   Command names list, and procedure lists
      integer*4 itscb(13,1)          !  time scheduling control block
      integer*2 ibuf(513)         !  input buffer containing command
      integer*2 ibuf2(513),ibufd(3)
      character*1024 ibc
      equivalence (ibc,ibuf)
      dimension itime(9)         !  time array returned from spars
      dimension it(6)          !  time from system 
      integer itn(6),itw(6)
c
      integer*2 lsors
      integer*4 irec,id
      integer fmpsetpos, fmpposition, fmpreadstr
      integer perror
c
      integer*4 secsnow,secswait,delta
      dimension iotref(3),istref(3)
C                         Ref times for operator and schedule streams
      character*20 cnamef,tmpstr   !  file name, general use
      dimension lnamef(10),tmpchr(10) !  file name, general use
      equivalence (lnamef,cnamef),(tmpchr,tmpstr)
      integer idcbp1(2),idcbp2(2),fc_system,fc_skd_end_insnp,fc_if_cmd
      integer fc_find_process
      save idcbp1,idcbp2
C                         DCB's for procedures from lists 1 and 2
      dimension istksk(42),istkop(42)        !  stacks for nested procedures
      dimension lprocn(6)          !  name of currently-executing procedure
      dimension lprocs(6),lproco(6)
C                   Names of schedule, operator top-of-stack procedures
      dimension lstksk(2+MAX_PROC_PARAM_COUNT)
      dimension lstkop(2+MAX_PROC_PARAM_COUNT)
      dimension lpparm(MAX_PROC_PARAM_WORDS)
C                   Stacks for procedure parameters, parameter string
C     NCPARM - # chars in procedure parameter string
      dimension itmlog(6)          !  time log file was opened
      integer*4 icurln,ilstln
      character*12 ibc1,ibc2
      dimension ireg(2)
      integer get_buf, ichcm_ch, rn_take
      logical rn_test,kxdisp,kxlog,kput
      equivalence (ireg(1),reg)
      integer jchar, itype
      integer disk_record_record
      character cjchar,chsor,char2
      character*12 setup_proc
      integer trimlen
      logical krcur,klast,kts,kskblk,kopblk,kbreak,kstak,kon
      character*256 display_server_envar
C                   KRCUR returns true if a procedure calls itself
C                   KPAST returns true if a given time is earlier than now
C                   KLAST true if this is last time scheduling of command
C                   KTS true if command was time-scheduled
C                   KSKBLK true if schedule is blocked waiting for time
C                   KOPBLK true if operator is blocked waiting for time
C                   KBREAK is true if operator wants to break a proc
C                   KSTAK returns true if the stacks contain procs from
C                          one of the libraries
C                   KON is a temporary logical variable
C     ICLASS - general variable for class with command/response
C     ICLOP2 - secondary operator class after immediate commands
C             have been stripped
C     MAXPR1,2 - Maximum number of procs allowed in each lists

      external stat

      data iblen/512/
      data kskblk/.true./,kopblk/.false./,kxdisp/.false./,kxlog/.false./
      data istksk/40,2,40*0/, istkop/40,2,40*0/
      data lstksk/MAX_PROC_PARAM_COUNT,2,MAX_PROC_PARAM_COUNT*0/
      data lstkop/MAX_PROC_PARAM_COUNT,2,MAX_PROC_PARAM_COUNT*0/
      data nproc1/0/, nproc2/0/
      data lsors/2h::/
C
C**********************************************************************
C
C     1. Initialize.
C
      setup_proc=' '
      call fc_rte_time(itmlog,itmlog(6))
      iclass = 0
      iclop2 = 0
      idcbp1(1)=0
      idcbp1(2)=0
      idcbp2(1)=0
      idcbp2(2)=0
      call fc_rte_time(it,it(6))
      iotref(1) = (it(6)-1970)*1024 + it(5)
      iotref(2) = it(4)*60 + it(3)
      iotref(3) = it(2)*100+it(1)
      istref(1) = iotref(1)
      istref(2) = iotref(2)
      istref(3) = iotref(3)
      call char2hol('/',lsor2,1,1)
      lstp2 = 'station'
      call char2hol(lstp2,ilstp2,1,MAX_SKD)
      call fs_set_lstp2(ilstp2)
      call char2hol(lstp2,ilstp,1,8)
      call fs_set_lstp(ilstp)
      call opnpf(lstp2,idcbp2,ibuf,iblen,lproc2,maxpr2,nproc2,ierr,'n')
      if (ierr.lt.0) call logit7ci(0,0,0,1,-133,'bo',ierr)
      iwait=0
      ipinsnp(1)=0
      ipinsnp(3)=0
C
C     2. First and always, check the time list for something to do.
C     This is the highest priority.  Get next job, or next time to awaken.
C     Check for any newly edited proc files sent by PFMED.
C
200   continue
c      write(6,*) 'iwait',iwait
      if(iwait.ne.0) then
         iret=fc_skd_end_insnp('boss ',ipinsnp)
         if(iret.ne.0) then
            call clrcl(ipinsnp(1))
         endif
      endif
      iwait=0
      ipinsnp(1)=0
      ipinsnp(2)=0
      ipinsnp(3)=0
      call newpf(idcbp1,idcbp2,lproc1,maxpr1,nproc1,lproc2,maxpr2,
     .nproc2,ibuf,iblen,istkop,istksk)
      call getts(itscb,ntscb,itime,itype,index,iclass,lsor,indts,klast,
     .istksk,istkop)
C
C     2.1 If there's nothing to do (INDTS empty) go try
C     getting a command from one of the main streams.
C
220   continue
      if (indts.ne.0) then
C
C     2.2 If the time of a ! command has arrived, unblock
C     the appropriate command stream.
C
        if (cjchar(itype,1).eq.'!') then
          chsor = cjchar(lsor,2)
          if (chsor.eq.';') kopblk = .false.
          if (chsor.eq.':') kskblk = .false.
          goto 200
        endif
C
C     2.3 We do have a time-scheduled function to execute (INDEX non-zero).
C     First, log the command and then go to process.
C
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar = min0(ireg(2),iblen*2)
        call logit4(ibuf,nchar,lsor,lprocn)
        kts = .true.
        if (cjchar(itype,2).ne.'F') then
           indexold=index
           ichara = iscn_ch(ibuf,1,nchar,'=')
           if (ichara.eq.0) ichara=nchar+1
           icharb = iscn_ch(ibuf,1,nchar,'@')
           if (icharb.eq.0) icharb=nchar+1
           ichar1 = min0(ichara,icharb,nchar+1)
           call gtnam(ibuf,1,ichar1-1,lnames,nnames,lproc1,nproc1,
     .          lproc2,nproc2,ierr,itype,index)
           if (ierr.ne.0) then
              call logit7ci(0,0,0,0,ierr,'sp',0)
              call cants(itscb,ntscb,5,indexold,indts)
              call clrcl(iclass)
              if(iwait.ne.0) then
                 ipinsnp(3)=ierr
                 call char2hol('sp',ipinsnp(4),1,2)
                 ipinsnp(5)=0
              endif
              goto 200
           endif
        endif
        goto 500
      endif
C
C     3. Get a command from the schedule file or from a procedure file.
C     Check it out, log it, parse it, time-list if necessary, and
C     block command streams if appropriate.  Finally process.
C
      call fs_get_khalt(khalt)
      call getcm(istksk,istkop,lstksk,lstkop,idcbp1,idcbp2,idcbsk,
     .    kskblk,kopblk,khalt,kbreak,iclopr,iclop2,iblen,ibuf,
     .    nchar,lsor,lprocs,lproco,lpparm,ncparm,
     .    lnames,nnames,lproc1,nproc1,lproc2,nproc2,
     .    maxpr1,maxpr2,ierr,icurln,ilstln,iwait)
      if (ierr.eq.-1) ierr=0
      chsor = cjchar(lsor,2)
      if (chsor.eq.';') idummy = ichmv(lprocn,1,lproco,1,12)
      if (chsor.eq.':') idummy = ichmv(lprocn,1,lprocs,1,12)
C                   Establish the current procedure name
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-101,'bo',ierr)
        goto 200
      endif
C
C     3.1 If there is no work to do (NCHAR is zero), suspend.  The time to
C     awaken was decided by GETTS already when it passed on to this section.
C
      if (nchar.le.0) then
        if (ichcm_ch(lsor,1,'::').eq.0) then
          call logit4_ch('*end of schedule',lsor,lprocn)
          kskblk = .true.
          lskd2 = '    '
          call char2hol(lskd2,ilskd2,1,MAX_SKD)
          call fs_set_lskd2(ilskd2)
          call char2hol(lskd2,ilskd,1,8)
          call fs_set_lskd(ilskd)
          call fmpclose(idcbsk,ierr)
        endif
        call newpf(idcbp1,idcbp2,lproc1,maxpr1,nproc1,lproc2,maxpr2,
     &             nproc2,ibuf,iblen,istkop,istksk)
C                     Check one last time to see if perchance the stacks
C                     were flushed with the last call to GETCM
        call getts(itscb,ntscb,itime,itype,index,iclass,lsor,indts,
     &             klast,istksk,istkop)
C                     Also, check one last time for time-scheduled
C                     procs for the same reason
        if (indts.ne.0) goto 220
C                     Jump back into the command loop if there's
C                     something to do.  Not very elegant!
        iy = itime(1)/1024+1970
        id = mod(itime(1),1024)
        ih = itime(2)/60
        im = mod(itime(2),60)
        is = itime(3)/100
        ims = mod(itime(3),100)
        inext(1) = ih
        inext(2) = im
        inext(3) = is
        call fs_set_inext(inext)
        call char2hol('bo',ip,1,2)
C
C  figure out when to wake up
C
        call fc_rte_time(itn,itn(6))
        itw(1)=ims
        itw(2)=is
        itw(3)=im
        itw(4)=ih
        itw(5)=id
        itw(6)=iy
c not Y2038 compliant
        call fc_rte2secs(itn,secsnow)
        if(secsnow.lt.0) call logit7ci(0,0,0,1,-251,'bo',0)
c not Y2038 compliant
        call fc_rte2secs(itw,secswait)
        if(secsnow.lt.0) call logit7ci(0,0,0,1,-252,'bo',0)
c
c not Y2038 compliant
        delta=(secswait-secsnow)*100+itw(1)-itn(1)
        if(delta.gt.5*60*100.or.secsnow.lt.0.or.secswait.lt.0)
     &       delta=5*60*100
        kput=delta.gt.200
        if(kput) then
           call rn_put('fsctl')
           delta=delta-200
        endif
        if(delta.gt.1) call wait_relt('boss ',ip,1,delta)
        if(kput) then
           iold=rn_take('fsctl',0)
        endif
C                   Self-suspend, saving our suspension point
C********************************************************************
C***************THIS IS THE WAKE-UP POINT****************************
C********************************************************************
C
        goto 200
      endif
C
C     3.2 Log the command.  Parse it.
C
 320  continue
      jind = 1
      call spars(ibuf,jind,nchar,lnames,nnames,lproc1,nproc1,lproc2,
     .nproc2,lpparm,ncparm,itype,ierr,itime,index,iclass)
C*****NOTE***** IBUF IS EXPANDED IF THE PROCEDURE HAS ANY
C       PARAMETERS.  MAX 100 CHARS.  JIND AND NCHAR ARE MODIFIED.
C
      if (iclass.ne.0) then
         iclass = iclass+ocp60000
      endif
      call logit4(ibuf,nchar,lsor,lprocn)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,0,ierr,'sp',0)
        call clrcl(iclass)
        if(iwait.ne.0) then
           ipinsnp(3)=ierr
           call char2hol('sp',ipinsnp(4),1,2)
           ipinsnp(5)=0
        endif
        goto 200
      endif
C
C  3.3 Check out the command.
C     If the command was a comment, we're done now.
C
      kts = .false.
      if (ichcm_ch(itype,1,' c').eq.0) goto 200
C
C  3.4 Handle the time parameters.
C     If ! command has something after the !, adjust time
C     parameters wrt reference time.  Do nothing further if the command
C     was simply !*, otherwise block appropriate command stream.
C     If no time was specified, go to process.
C     If a time was specified, put command into time list.
C
      char2 = cjchar(itype,2)
      if (cjchar(itype,1).eq.'!') then
        chsor = cjchar(lsor,2)
        if (char2.ne.' ') then
          if (chsor.eq.':') call reftm(istref,itime,char2)
          if (chsor.eq.';') call reftm(iotref,itime,char2)
          if (itime(1).eq.-1) goto 200
        endif
        if (chsor.eq.':') kskblk = .true.
        if (chsor.eq.';') kopblk = .true.
      endif
C
      if ((itime(1).eq.0.or.itime(1).eq.-1).and.
     .     itime(4).eq.0.and.itime(7).eq.0) goto 500
      call putts(itscb,ntscb,itime,itype,index,iclass,lsor,ierr)
      if (ierr.lt.0) call logit7ci(0,0,0,1,-102,'bo',itime(1))
      if (ierr.lt.0) call clrcl(iclass)
      goto 200
C
C     5. This is the processing section.
C     Sub-sections process the following:
C                   5.0 Procedure set-up
C                   5.1 Functions - QUIKR/STQKR segments
C                   5.2 CONT command to undo HALT
C                   5.3 HALT command to stop schedule stream
C                   5.4 LOG command
C                   5.5 SCHEDULE command
C                   5.6 XLOG,XDISP,ECHO,CHECK commands
C                   5.10 TERMINATE command
C                   5.11 FLUSH command
C                   5.12 SY command
C                   5.13 TI command
C                   5.14 BREAK command
C                   5.15 PROC command
C                   5.16 LIST command
C                   5.17 STATUS command 
C                   5.18 HELP command
C
C
500   mbranch = lnames(10,index)
C
C     5.0 This is the procedure section.
C
      if (cjchar(itype,2).ne.'F') then
        indexp = index
        if (cjchar(itype,2).eq.'Q') indexp = -indexp
C                   Indicate the second list by <0
        chsor = cjchar(lsor,2)
        if ( (chsor.ne.';' .or. krcur(istkop,indexp)) .and.
     &       (chsor.ne.':' .or. krcur(istksk,indexp)) ) then
C                   Recursion is not allowed
          call logit6c(0,0,0,0,-103,'bo')
          if(iwait.ne.0) then
             ipinsnp(3)=-103
             call char2hol('bo',ipinsnp(4),1,2)
             ipinsnp(5)=0
          endif
          goto 600
        endif
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar = min0(ireg(2),iblen*2)
C                   Get the command <name>=<parm>
        ich = iscn_ch(ibuf,1,nchar,'=')
        if (ich.gt.0) then
          ncparm = nchar - ich
          if (ncparm.lt.0 .or. ncparm.gt.MAX_PROC_PARAM_CHARS) then
            call logit7ci(0,0,0,1,-135,'bo',MAX_PROC_PARAM_CHARS)
            if(iwait.ne.0) then
               ipinsnp(3)=-135
               call char2hol('bo',ipinsnp(4),1,2)
               ipinsnp(5)=0
            endif
            goto 600
          endif
          idummy = ichmv(lpparm,1,ibuf,ich+1,ncparm)
        else
          ncparm = 0
          ich = nchar+1
        endif
        chsor = cjchar(lsor,2)
        if (chsor.eq.';') then         !  get the operator stream procedure
          call ifill_ch(lproco,1,12,' ')
          idummy = ichmv(lproco,1,ibuf,1,ich-1)
          call newpr(idcbp1,idcbp2,istkop,indexp,
     .     lpparm,ncparm,lstkop,lproc1,lproc2,itmlog,ibuf,iblen,ierr)
        else                            !  get the schedule stream procedure
          call ifill_ch(lprocs,1,12,' ')
          idummy = ichmv(lprocs,1,ibuf,1,ich-1)
          call newpr(idcbp1,idcbp2,istksk,indexp,
     .     lpparm,ncparm,lstksk,lproc1,lproc2,itmlog,ibuf,iblen,ierr)
        endif
        if (ierr.lt.0) then
          if (kts) iclass = 0
          call clrcl(iclass)
          if (kts) call cants(itscb,ntscb,5,index,indts)
          goto 200
        endif
        if(kts) iclass = 0
        call clrcl(iclass)
C
C     5.1 This is the QUIKR/STQKR processing section.
C
      else if (mbranch.eq.1) then
         ip(3)=0
        if (ichcm_ch(lnames(7,index),1,'st').eq.0) then
          call run_prog('stqkr','wait',iclass,lnames(9,index),ip(3),
     .                   ip(4),ip(5))
        else if (ichcm_ch(lnames(7,index),1,'qk').eq.0) then
          isub = lnames(9,index)/100
          if (isub.ge.1.and.isub.le.21.or.isub.eq.76) then
            call run_prog('quikr','wait',iclass,lnames(9,index),ip(3),
     .                   ip(4),ip(5))
            call read_quikr
          else if (isub.ge.22) then
            call run_prog('quikv','wait',iclass,lnames(9,index),ip(3),
     .                   ip(4),ip(5))
          end if
        end if
        call rmpar(ip)
C                   Don't leave just yet!  See if there is any
C                   messages, regardless if there is an error or not.
        if (ip(1).ne.0) then
          do i=1,ip(2)
            ireg(2) = get_buf(ip(1),ibuf,-iblen*2,idum,idum)
            nchar = min0(ireg(2),iblen*2)
            call char2hol('/ ',ldum,1,2)
            call logit4(ibuf,nchar,ldum,lprocn)
            if(iwait.ne.0) then
               call put_buf(ipinsnp(1),ibuf,-nchar,'  ','  ')
               ipinsnp(2)=ipinsnp(2)+1
            endif
          enddo
        endif
        if (kts) iclass = 0
        call clrcl(iclass)
c
c   now check for errors and warnings
c
        if (ip(3).ne.0) then
           call logit7(0,0,0,0,ip(3),ip(4),ip(5))
        endif
c
c now clean-up from an error
c
        if (ip(3).lt.0) then
          if (kts) iclass=0
C                   If we got ICLASS from time-scheduling, don't kill
C                   it here, wait until CANTS
          if(iwait.ne.0) then
             ipinsnp(3)=ip(3)
             ipinsnp(4)=ip(4)
             ipinsnp(5)=ip(5)
             ip(5)=0
          endif
          call clrcl(iclass)
          if(kts) call cants(itscb,ntscb,5,index,indts)
          if (ip(1).eq.0) goto 200
        endif
        ip(5)=0
C
C     5.2 Handle CONT command.  Set KHALT to false now.
C
      else if (mbranch.eq.2) then
        khalt = .false.
        call fs_set_khalt(khalt)
C
C     5.3 This is the HALT command.
C
      else if (mbranch.eq.3) then
        khalt = .true.
        call fs_set_khalt(khalt)
C
C     5.4 This section processes the LOG=xx command.  Similar
C     to initialization code in BINIT for log files.
C
      else if (mbranch.eq.4) then
        call ifill_ch(ibuf,1,iblen*2,' ')
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar = min0(ireg(2),iblen*2)
        ich = 1+iscn_ch(ibuf,1,nchar,'=')
        if (ich.eq.(nchar+1)) then
          ich=1
          nchar=nchar-1
        endif
        if (ich.eq.1) then
          nch = ichmv_ch(ibuf,nchar+1,'/')
          call fs_get_llog2(illog2)
          nch = nch + ichmv(ibuf,nch,illog2,1,MAX_SKD)
          nch=1+iflch(ibuf,nch-1)
          call logit4(ibuf,nch-1,lsor2,lprocn)
          if(iwait.ne.0) then
             call put_buf(ipinsnp(1),ibuf,-(nch-1),'  ','  ')
             ipinsnp(2)=ipinsnp(2)+1
          endif
        else
C                   User requested log name, format response and log it.
          ic2 = iscn_ch(ibuf,ich,nchar,',')
          if (ic2.eq.0) ic2 = nchar+1
          if(ic2-ich.gt.MAX_SKD) then
             call logit7ci(0,0,0,1,-262,'bo',MAX_SKD)
             goto 600
          endif
          llog2=' '
          llog2(1:ic2-ich) = ibc(ich:ic2-1)
          call char2hol(llog2,illog2,1,MAX_SKD)
          call fs_set_llog2(illog2)
          call char2hol(llog2,illog,1,8)
          call fs_set_llog(illog)
          call newlg(ibuf,lsor)
C                   Start the new log file
          call fc_rte_time(itmlog,itmlog(6))
C                   Record the time the new log was started
        endif
C
C     5.5 SCHEDULE command section.
C
      else if (mbranch.eq.5) then
         ich = 1+iscn_ch(ibuf,1,nchar,'=')
C  User requested schedule name, format response and log it.
         if (ich.eq.1) then
            nch = ichmv_ch(ibuf,nchar+1,'/')
            call fs_get_lskd2(ilskd2)
            call hol2char(ilskd2,1,MAX_SKD,lskd2)
            ibc(nch:) = lskd2
            nch=nch+trimlen(lskd2)
            nch = mcoma(ibuf,nch)
            if (ierr.lt.0) icurln=0
            nch = nch+ib2as(icurln,ibuf,nch,ocp100000+5)
            call logit4(ibuf,nch-1,lsor2,lprocn)
            if(iwait.ne.0) then
               call put_buf(ipinsnp(1),ibuf,-(nch-1),'  ','  ')
               ipinsnp(2)=ipinsnp(2)+1
            endif
            goto 600
         endif
         call fs_get_disk_record_record(disk_record_record)
         if(disk_record_record.eq.1) then
             call logit7ci(0,0,0,0,-263,'bo',0)
             goto 600
          endif
        irnprc = rn_take('pfmed',1)
        if (irnprc.eq.0) then
          call ifill_ch(ibuf,1,iblen*2,' ')
          ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
          nchar = min0(ireg(2),iblen*2)
          ich = 1+iscn_ch(ibuf,1,nchar,'=')
          ic4 = iscn_ch(ibuf,ich,nchar,',')
          if (ic4.eq.0) ic4 = nchar + 1
          ic2 = iscn_ch(ibuf,ich,ic4-1,' ')
          if(ic2.ne.0) then
             call logit7ci(0,0,0,1,-265,'bo',0)
             call rn_put('pfmed')
             goto 600
          endif
          if(ic4-1-ich+1.gt.MAX_SKD) then
             call logit7ci(0,0,0,1,-261,'bo',MAX_SKD)
             call rn_put('pfmed')
             goto 600
          endif
          cnamef=' '
          if(ich.le.ic4-1) then
             cnamef = ibc(ich:ic4-1)
          endif
          if(cnamef.ne.' ') then
              call fc_access(
     &            FS_root//'/sched/'//ibc(ich:ic4-1)//'.snp','r',
     &            ierr,perror)
              if(ierr.ne.0) then
                  if(ierr.gt.0.or.ierr.lt.-4) then
                      call logit7ci(0,0,0,1,-209,'bo',perror)
                  else
                      call logit7ci(0,0,0,1,-204+ierr,'bo',perror)
                  endif
                  call rn_put('pfmed')
                  goto 600
              endif
          endif
          if(kstak(istkop,istksk,1)) then
             call logit7ci(0,0,0,0,-211,'bo',0)
             if(iwait.ne.0) then
                ipinsnp(3)=-211
                call char2hol('bo',ipinsnp(4),1,2)
                ipinsnp(5)=0
             endif
             call rn_put('pfmed')
             goto 600
          endif           
          istksk(2) = 2
          lstksk(2) = 2
          call cants(itscb,ntscb,4,0,0)
          call cants(itscb,ntscb,2,0,0)
C  if the scehdule file name is blank don't try to open it.
          if(cnamef.eq.' ') then
             call fmpclose(idcbsk,ierr)
             kskblk = .true.
             lskd2 = '    '
             call char2hol(lskd2,ilskd2,1,MAX_SKD)
             call fs_set_lskd2(ilskd2)
             call char2hol(lskd2,ilskd,1,8)
             call fs_set_lskd(ilskd)
             call rn_put('pfmed')
             goto 600
          endif
C  Initialize, if we've got this far we must be
C  a valid schedule or all is set to zero.
          il = iflch(lnamef,20)
          ic1=iscn_ch(lnamef,1,20,'/')
          ic2=iscn_ch(lnamef,ic1+1,20,'/')
          ic3=iscn_ch(lnamef,1,20,'.')
          if(ic3.gt.0) then
            ibc2=cnamef(ic3:il)
            il2=il-ic3+1
          else
            ibc2='.snp'
            ic3=il+1
            il2=4
          endif
          if(ic2.gt.0) then
            ibc1=cnamef(ic1:ic2)
            il1=ic2-ic1+1
          else
            ibc1=FS_ROOT//'/sched/'
            il1=12
          endif     
          lskd2 = cnamef(ic2+1:ic3-1)
          call char2hol(lskd2,ilskd2,1,MAX_SKD)
          call fs_set_lskd2(ilskd2)
          call char2hol(lskd2,ilskd,1,8)
          call fs_set_lskd(ilskd)
          call fmpopen(idcbsk,
     &     ibc1(1:il1) // lskd2(1:ic3-ic2-1) // ibc2(1:il2),
     &     ierr,'r',id)
          if (ierr.lt.0) then
             call logit7ci(0,0,0,1,-105,'bo',ierr)
             if(iwait.ne.0) then
                ipinsnp(3)=-105
                call char2hol('bo',ipinsnp(4),1,2)
                ipinsnp(5)=0
             endif
             kskblk = .true.
             lskd2 = '    '
             call char2hol(lskd2,ilskd2,1,MAX_SKD)
             call fs_set_lskd2(ilskd2)
             call char2hol(lskd2,ilskd,1,8)
             call fs_set_lskd(ilskd)
             call rn_put('pfmed')
             goto 600
          endif
          ich = ic4+1
          ierr = 0
          call newsk(ibuf,ich,nchar,idcbsk,iblen,ierr,icurln,ilstln)
          if (ierr.ne.0) then
             kskblk = .true.
             lskd2 = '    '
             call char2hol(lskd2,ilskd2,1,MAX_SKD)
             call fs_set_lskd2(ilskd2)
             call char2hol(lskd2,ilskd,1,8)
             call fs_set_lskd(ilskd)
            call rn_put('pfmed')
            goto 600
          endif
          kskblk = .false.
          khalt = .false.
          call fs_set_khalt(khalt)
          setup_proc=' '
c    
          call fs_get_lprc2(ilprc2)
          call hol2char(ilprc2,1,MAX_SKD,lprc2)
          if(lprc2.ne.'    '.and.lprc2.ne.' ') then
              call fmpclose(idcbp1,ierr)
              lprc2='    '
              call char2hol(lprc2,ilprc2,1,MAX_SKD)
              call fs_set_lprc2(ilprc2)
              call char2hol(lprc2,ilprc,1,8)
              call fs_set_lprc(ilprc)
              nproc1 = 0
          endif
c
          call fs_get_lskd2(ilskd2)
          call hol2char(ilskd2,1,MAX_SKD,lskd2)
          if (lskd2.eq.'station') then
              call logit7ci(0,0,0,1,-158,'bo',ierr)
              if(iwait.ne.0) then
                 ipinsnp(3)=-158
                 call char2hol('bo',ipinsnp(4),1,2)
                 ipinsnp(5)=0
              endif
              call rn_put('pfmed')
              goto 600
          end if
c
          call fs_get_lskd2(ilskd2)
          call hol2char(ilskd2,1,MAX_SKD,lskd2)
          call opnpf(lskd2,idcbp1,ibuf,iblen,lproc1,maxpr1,nproc1,ierr,
     &               'n')
          if (ierr.lt.0) then
            if(ierr.ne.-6) then
              call logit7ci(0,0,0,1,-133,'bo',ierr)
              if(iwait.ne.0) then
                 ipinsnp(3)=-133
                 call char2hol('bo',ipinsnp(4),1,2)
                 ipinsnp(5)=ierr
              endif
            else
              call logit7ci(0,0,0,1,-139,'bo',ierr)
              if(iwait.ne.0) then
                 ipinsnp(3)=-139
                 call char2hol('bo',ipinsnp(4),1,2)
                 ipinsnp(5)=ierr
                 endif
            endif
            lprc2='    '
            call char2hol(lprc2,ilprc2,1,MAX_SKD)
            call fs_set_lprc2(ilprc2)
            call char2hol(lprc2,ilprc,1,8)
            call fs_set_lprc(ilprc)
            nproc1 = 0
          else
            call fs_get_lskd2(ilskd2)
            call hol2char(ilskd2,1,MAX_SKD,lskd2)
            lprc2 = lskd2
            call char2hol(lprc2,ilprc2,1,MAX_SKD)
            call fs_set_lprc2(ilprc2)
            call char2hol(lprc2,ilprc,1,8)
            call fs_set_lprc(ilprc)
          endif
          call fs_get_lskd2(ilskd2)
          call hol2char(ilskd2,1,MAX_SKD,lskd2)
          call fs_get_llog2(illog2)
          call hol2char(illog2,1,MAX_SKD,llog2)
          if (llog2.ne.lskd2) then
            llog2 = lskd2
            call char2hol(llog2,illog2,1,MAX_SKD)
            call fs_set_llog2(illog2)
            call char2hol(llog2,illog,1,8)
            call fs_set_llog(illog)
            call newlg(ibuf,lsor)
            call fc_rte_time(itmlog,itmlog(6))
          endif
          call rn_put('pfmed')
C
C log all the leading comments in the schedule
C
          idum = fmpposition(idcbsk,ierr,irec,id)
          idum = fmpsetpos(idcbsk,ierr,0,id)
          ilen = fmpreadstr(idcbsk,ierr,ibc)
          do while (cjchar(ibuf,1).eq.'"')
             call logit4(ibuf,ilen,lsors,lproc)
             ilen = fmpreadstr(idcbsk,ierr,ibc)
          enddo
          idum = fmpsetpos(idcbsk,ierr,irec,id)
        else
          call logit7ci(0,0,0,0,-159,'bo',0)
          goto 600
        end if
        scan_name_old(1:1)=char(0)
        call fs_set_scan_name_old(scan_name_old)
        scan_name(1:1)=char(0)
        call fs_set_scan_name(scan_name)
        idum=ichmv_ch(ibuf,1,"exper_initi")
        nchar=idum-1
        idum=ichmv_ch(lsor,1,"::")
c
c this code after the loop termination had to be added to keep things okay
c
        mbranch = 0
        if (.not.kts) call clrcl(iclass)
        if (kts.and.klast) call cants(itscb,ntscb,5,index,indts)
        ierr = 0
c
        if(iwait.ne.0) then
           iret=fc_skd_end_insnp('boss ',ipinsnp)
           if(iret.ne.0) then
              call clrcl(ipinsnp(1))
           endif
        endif
        iwait=0
        ipinsnp(1)=0
        ipinsnp(2)=0
        ipinsnp(3)=0
        goto 320
C
C     5.6 Commands which set switches (XLOG,ECHO,XDISP)
C
      else if (mbranch.ge.6 .and. mbranch.le.9) then
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar = min0(ireg(2),iblen*2)
        ich = 1+iscn_ch(ibuf,1,nchar,'=')
        if (ich.eq.1) then
          call logit7ci(0,0,0,0,-107,'bo',0)
          if(iwait.ne.0) then
             ipinsnp(3)=-107
             call char2hol('bo',ipinsnp(4),1,2)
             ipinsnp(5)=0
          endif
        else
          kon = (ichcm_ch(ibuf,ich,'on').eq.0)
          if (.not.kon .and. ichcm_ch(ibuf,ich,'off').ne.0) then
            call logit7ci(0,0,0,0,-108,'bo',0)
            if(iwait.ne.0) then
               ipinsnp(3)=-108
               call char2hol('bo',ipinsnp(4),1,2)
               ipinsnp(5)=0
            endif
          else
            if (mbranch.eq.6) then
              kxlog = kon
              if (kon) call put_buf(iclbox,ibuf,-1,'fs','ln')
              if (.not.kon) call put_buf(iclbox,ibuf,-1,'fs','lf')
            endif
            if (mbranch.eq.7) then
              kxdisp = kon
              if (kon) call put_buf(iclbox,ibuf,-1,'fs','dn')
              if (.not.kon) call put_buf(iclbox,ibuf,-1,'fs','df')
            endif
            if (mbranch.eq.8) kecho=kon
            call fs_set_kecho(kecho)
            if (mbranch.eq.9) kcheck=kon
          endif
        endif
C
C     5.10 TERMINATE command--the only way to leave this program
C
      else if (mbranch.eq.10) then
         ierr=0
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        if (rn_test('pfmed')) then
          call logit7ci(0,0,0,0,-171,'bo',0)
          if(iwait.ne.0) then
             ipinsnp(3)=-171
             call char2hol('bo',ipinsnp(4),1,2)
             ipinsnp(5)=0
          endif
          goto 600
        endif
        nchar = min0(ireg(2),iblen*2)
        ich = 1+iscn_ch(ibuf,1,nchar,'=')
        if (ich.ne.1) then
           if(ichcm_ch(ibuf,ich,'force').ne.0) then
              call logit7ci(0,0,0,0,-172,'bo',0)
              if(iwait.ne.0) then
                 ipinsnp(3)=-172
                 call char2hol('bo',ipinsnp(4),1,2)
                 ipinsnp(5)=0
              endif
              goto 600
           endif
        else
           call fs_get_disk_record_record(disk_record_record)
           if(disk_record_record.eq.1) then
              call logit7ci(0,0,0,0,-173,'bo',0)
           endif
           call getenv('FS_DISPLAY_SERVER', display_server_envar)
           if (display_server_envar .ne. "off") then
              ipida=fc_find_process('autoftp'//char(0),ierr)
              if(ipida.ge.0) then
                 call logit7ci(0,0,0,0,-174,'bo',0)
              else if(ipida.gt.-8) then
                 if(ipida.gt.-5) then
                    call logit7ci(0,0,0,0,ierr,'un',0)
                 endif
                 call logit7ci(0,0,0,1,-177,'bo',ipida)
              endif
              ipidf=fc_find_process('fs.prompt'//char(0),ierr)
              if(ipidf.ge.0) then
                 call logit7ci(0,0,0,0,-175,'bo',0)
              else if(ipidf.gt.-8) then
                 if(ipidf.gt.-5) then
                    call logit7ci(0,0,0,0,ierr,'un',0)
                 endif
                 call logit7ci(0,0,0,1,-178,'bo',ipidf)
               endif
           else
              ipida=-8
              ipidf=-8
           endif
           if(disk_record_record.eq.1.or.
     &        ipida.ne.-8.or.ipidf.ne.-8) then
              call logit7ci(0,0,0,0,-176,'bo',0)
              if(iwait.ne.0) then
                 ipinsnp(3)=-176
                 call char2hol('bo',ipinsnp(4),1,2)
                 ipinsnp(5)=0
              endif
              goto 600
           endif
        endif
        do i=1,20
          icheck(i)=0
          call fs_set_icheck(icheck(i),i)
        enddo
        call fmpclose(idcbsk,ierr)
        call fmpclose(idcbp1,ierr)
        call fmpclose(idcbp2,ierr)
        call clrcl(iclass)
        call clrcl(iclopr)
        call clrcl(iclop2)
        call char2hol('::',ldum,1,2)
        call logit4_ch('*boss terminated',ldum,lprocn)
        if(iwait.ne.0) then
           iret=fc_skd_end_insnp('boss ',ipinsnp)
           if(iret.ne.0) then
              call clrcl(ipinsnp(1))
           endif
        endif
        call fc_antcn_term(iout)
        if(iout.ge.0) then
           ip(1)=iout
           call run_prog('antcn','wait',ip(1),ip(2),ip(3),ip(4),ip(5))
           call rmpar(ip)
           ierr = ip(3)
           if (ierr.ne.0) then
              call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
              call logit7ci(0,0,0,1,-998,'bo',ierr)
           else
              call fc_rte_sleep(10)
              call fc_putln('antenna termination succeeded')
           endif
        endif
        call fc_rte_sleep( 10)
        return
C
C     5.11 FLUSH command to clear out the operator stream completely.
C     Reinitialize everything.
C
      else if (mbranch.eq.11) then
        ireg(2) = get_buf(iclop2+ocp120000,ibuf,-iblen*2,idum,idum)
        do while (ireg(2).ge.0)
          nchar = iflch(ibuf,min0(ireg(2),iblen*2))
          call put_cons(ibuf,nchar)
          ireg(2) = get_buf(iclop2+ocp120000,ibuf,-iblen*2,idum,idum)
        enddo
        istkop(2) = 2
        lstkop(2) = 2
        kopblk = .false.
        call cants(itscb,ntscb,3,0,0)
C
C     5.12 Section handling SY messages
C
      else if (mbranch.eq.12) then
        nch = iscn_ch(ibuf,1,nchar,'=')
        if (nch.eq.0) goto 600
        nch = ichmv(ibuf,1,ibuf,nch+1,nchar-nch)
        nch = ichmv(ibuf,nch,0,1,1)-1
        call rn_put('fsctl')
        nch= fc_system(ibuf)
        iold=rn_take('fsctl',0)
cxx        nchar = -messs(ibuf,nch)
c       if (nchar.gt.0) call logit4(ibuf,nchar,2H/ ,lprocn)
C
C     5.13 Section to handle TI command to list time list
C
      else if (mbranch.eq.13) then
        call ifill_ch(ibuf,1,iblen*2,' ')
        do i=1,ntscb
          if (itscb(1,i).ne.-1) then
            idummy = ichmv(ibuf,1,itscb(10,i),1,2)
C                     First the type
            if (jchar(ibuf,1).eq.0) idummy = ichmv_ch(ibuf,1,' ')
            if (jchar(ibuf,2).eq.0) idummy = ichmv_ch(ibuf,2,' ')
            idummy = ichmv(ibuf,3,itscb(13,i),2,1)
C                     Next the source of the command
            idummy = ib2as(itscb(11,i),ibuf,4,4)
C                     The index in the function or proc lists
            idummy = ichmv_ch(ibuf,8,'@')
       idummy = ib2as(itscb(1,i)/1024+1970,ibuf,9,ocp40000+ocp400*4+4)
       idummy = ichmv_ch(ibuf,13,'.')
       idummy = ib2as(mod(itscb(1,i),1024),ibuf,14,ocp40000+ocp400*3+3)
       idummy = ichmv_ch(ibuf,17,'.')
       idummy = ib2as(itscb(2,i)/60,ibuf,18,ocp40000+ocp400*2+2)
       idummy = ichmv_ch(ibuf,20,':')
       idummy = ib2as(mod(itscb(2,i),60),ibuf,21,ocp40000+ocp400*2+2)
       idummy = ichmv_ch(ibuf,23,':')
       idummy = ib2as(itscb(3,i)/100,ibuf,24,ocp40000+ocp400*2+2)
       idummy = ichmv_ch(ibuf,26,'.')
       idummy = ib2as(mod(itscb(3,i),100),ibuf,27,ocp40000+ocp400*2+2)
       idummy = ichmv_ch(ibuf,29,'   ')
C                     The time next scheduled
            icl = itscb(12,i)
            nch = 0
            if (icl.ne.0) then
              ireg(2) = get_buf(icl,ibuf(16),-(iblen-16),idum,idum)
              nch = ireg(2)
C                     Get the buffer in the class
            endif
            call logit4(ibuf,min0(30+nch,iblen*2),lsor2,lprocn)
            if(iwait.ne.0) then
           call put_buf(ipinsnp(1),ibuf,-min0(30+nch,iblen*2),'  ','  ')
           ipinsnp(2)=ipinsnp(2)+1
            endif
          endif
        enddo
C
C     5.14 BREAK command sets the variable KBREAK to true.
C     This is passed to GETCM, thence to READP, and the
C     "end of a procedure" condition is forced.
C     Set this flag only if there's a procedure to be broken.
C     Otherwise, no effect.
C
      else if (mbranch.eq.14) then
        if (istkop(2).gt.2 .or. istksk(2).gt.2) kbreak = .true.
C
C     5.15 PROC command: new schedule procedure library
C
      else if (mbranch.eq.15) then
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar = min0(ireg(2),iblen*2)
        ich = 1+iscn_ch(ibuf,1,nchar,'=')
        if (ich.eq.(nchar+1)) then
          irnprc = rn_take('pfmed',1)
          if (irnprc.eq.0) then
            call fmpclose(idcbp1,ierr)
            lprc2='    '
            call char2hol(lprc2,ilprc2,1,MAX_SKD)
            call fs_set_lprc2(ilprc2)
            call char2hol(lprc2,ilprc,1,8)
            call fs_set_lprc(ilprc)
            nproc1 = 0
            call rn_put('pfmed')
          else
            call logit7ci(0,0,0,0,-157,'bo',0)
            if(iwait.ne.0) then
               ipinsnp(3)=-157
               call char2hol('bo',ipinsnp(4),1,2)
               ipinsnp(5)=0
             endif
          end if
          goto 600
        endif
        if (ich.eq.1) then         !  request for procedure file name
          nch = ichmv_ch(ibuf,nchar+1,'/')
          call fs_get_lprc2(ilprc2)
          call hol2char(ilprc2,1,MAX_SKD,lprc2)
          ibc(nch:) = lprc2(:trimlen(lprc2))
          nch = nch+trimlen(lprc2)
          call logit4(ibuf,nch-1,lsor2,lprocn)
          if(iwait.ne.0) then
             call put_buf(ipinsnp(1),ibuf,-(nch-1),'  ','  ')
             ipinsnp(2)=ipinsnp(2)+1
          endif
        else
          ic2 = iscn_ch(ibuf,ich,nchar,' ')
          if(ic2.ne.0) then
             call logit7ci(0,0,0,1,-264,'bo',0)
             goto 600
          endif
          ic2 = iscn_ch(ibuf,ich,nchar,',')
          if (ic2.eq.0) ic2 = nchar+1
          if(ic2-1-ich+1.gt.MAX_SKD) then
             call logit7ci(0,0,0,1,-260,'bo',MAX_SKD)
             goto 600
          endif
          call fs_get_lstp2(ilstp2)
          call hol2char(ilstp2,1,MAX_SKD,lstp2)
          if (kstak(istkop,istksk,1)) then
            call logit7ci(0,0,0,0,-212,'bo',0)
          else if (ibc(ich:ic2-1).eq.lstp2) then
C  the station procedure library is opened on startup and remains open
C  therefore, station as a procedure command parameter is an error.
            call logit7ci(0,0,0,0,-136,'bo',0)
          else
C check for write access/existence
            call fc_access(
     &         FS_root//'/proc/'//ibc(ich:ic2-1)//'.prc','rw',
     &         ierr,perror)
            if(ierr.ne.0) then
                if(ierr.gt.0.or.ierr.lt.-4) then
                    call logit7ci(0,0,0,1,-204,'bo',perror)
                else
                    call logit7ci(0,0,0,1,-199+ierr,'bo',perror)
                endif
                goto 5152
            endif
            irnprc = rn_take('pfmed',1)
            if (irnprc.eq.0) then
              call fs_get_lprc2(ilprc2)
              call hol2char(ilprc2,1,MAX_SKD,lprc2)
              if (lprc2.ne.ibc(ich:ic2-1)) call cants(itscb,ntscb,2,0,0)
C                   Cancel procs from the old library
C                   not doing it when the new proc is the same is questionable
              call fmpclose(idcbp1,ierr)
              lprc2='    '
              call char2hol(lprc2,ilprc2,1,MAX_SKD)
              call fs_set_lprc2(ilprc2)
              call char2hol(lprc2,ilprc,1,8)
              call fs_set_lprc(ilprc)
              nproc1 = 0
              lprc2 = ibc(ich:ic2-1)
              call char2hol(lprc2,ilprc2,1,MAX_SKD)
              call fs_set_lprc2(ilprc2)
              call char2hol(lprc2,ilprc,1,8)
              call fs_set_lprc(ilprc)
              call opnpf(lprc2,idcbp1,ibuf,iblen,lproc1,maxpr1,nproc1,
     &                   ierr,'n')
              if (ierr.ne.0) then
                call logit7ci(0,0,0,1,-133,'bo',ierr)
                lprc2 = '    '
                call char2hol(lprc2,ilprc2,1,MAX_SKD)
                call fs_set_lprc2(ilprc2)
                call char2hol(lprc2,ilprc,1,8)
                call fs_set_lprc(ilprc)
                nproc1 = 0
              endif
            else
              call logit7ci(0,0,0,0,-157,'bo',0)
              goto 5152
            endif
            call rn_put('pfmed')
5152        continue
          endif
        endif
C
C     5.16  LIST Command.
C
      else if (mbranch.eq.16) then
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar=min0(ireg(2),iblen*2)
        call fs_get_lskd2(ilskd2)
        call hol2char(ilskd2,1,MAX_SKD,lskd2)
        if (lskd2.eq.'    ') then
          call putcon_ch('no schedule currently active')
          if(iwait.ne.0) then
          idum=ichmv_ch(ibuf,1,'no schedule currently active')-1
             call put_buf(ipinsnp(1),idum,-nchar,'  ','  ')
             ipinsnp(2)=ipinsnp(2)+1
          endif
        else
          call lists(idcbsk,ibuf,nchar,icurln,iwait,ipinsnp)
        endif
C
C     5.17  STATUS Command.
C
      else if (mbranch.eq.17) then
        call fs_get_lskd2(ilskd2)
        call hol2char(ilskd2,1,MAX_SKD,lskd2)
        if (lskd2.eq.'    ') then
          call putcon_ch('no schedule currently active')
          if(iwait.ne.0) then
          idum=ichmv_ch(ibuf,1,'no schedule currently active')-1
             call put_buf(ipinsnp(1),ibuf,-idum,'  ','  ')
             ipinsnp(2)=ipinsnp(2)+1
          endif
        else
          call fs_get_khalt(khalt)
          call fs_get_lskd2(ilskd2)
          call hol2char(ilskd2,1,MAX_SKD,lskd2)
          call stat(ibuf,khalt,kopblk,kskblk,icurln,idcbsk,
     .         itscb,ntscb,lskd2,iwait,ipinsnp)
        endif
C
C     5.18  HELP command
C
      else if (mbranch.eq.18) then
        istart = iscn_ch(ibuf,1,nchar,'=')
        if ((istart.ne.0).and.(nchar.gt.istart)) then
          istart=istart+1
        else
          istart=0
        endif
        call fshelp(ibuf,istart,nchar,ierr)
        if(ierr.eq.-2.or.ierr.eq.-3) then
           call logit7ci(0,0,0,0,-306+ierr,'bo',0)
        endif
      else if (mbranch.eq.19) then
         nch = ichmv_ch(ibuf,nchar+1,'/')
         call logit4d(ibuf,nch-1,lsor2,lprocn)
      else if(mbranch.eq.20) then
        istart = iscn_ch(ibuf,1,nchar,'=')
        if(istart.ne.0.and.istart.lt.nchar) then
           nch = ichmv(ibuf2,1,ibuf,istart+1,nchar-istart)
           call copin(ibuf2,nch-1)
        endif
      else if (mbranch.eq.21) then
c
c TNX command
c
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar = min0(ireg(2),iblen*2)
        ich = 1+iscn_ch(ibuf,1,nchar,'=')
        if (ich.eq.1) then
             call put_buf(iclbox,ibuf,-1,'fs','tl')
        else
           call gtprm2(ibuf,ich,nchar,0,parm,ierr)
           if(ierr.ne.0) then
              call logit7ci(0,0,0,0,-300,'bo',0)
           else if(cjchar(lsor,1).eq.'$') then
              call logit7ci(0,0,0,0,-305,'bo',0)
           else if(cjchar(lsor,1).eq.'@') then
              call logit7ci(0,0,0,0,-306,'bo',0)
           else if(cjchar(lsor,2).eq.':') then
              call logit7ci(0,0,0,0,-307,'bo',0)
           else
              ibufd(1)=iparm(1)
              call gtprm2(ibuf,ich,nchar,1,parm,ierr)
              if (ierr.ne.0) then
                 call logit7ci(0,0,0,0,-301,'bo',0)
              else 
                 ioffon=-1
                 ibufd(2)=iparm(1)
                 call gtprm2(ibuf,ich,nchar,0,parm,ierr)
                 if(ierr.lt.0) then
                    call logit7ci(0,0,0,0,-302,'bo',0)
                 else if(0.eq.ichcm_ch(parm,1,'on')) then
                    ioffon=1
                 else if(0.eq.ichcm_ch(parm,1,'off').or.
     &                   ierr.eq.2) then
                    ioffon=0
                 else   
                    call logit7ci(0,0,0,0,-302,'bo',0)
                 endif
                 if(iffon.ne.-1) then
                    call gtprm2(ibuf,ich,nchar,0,parm,ierr)
                    if(ierr.lt.0.or.ierr.eq.1) then
                       call logit7ci(0,0,0,0,-310,'bo',0)
                    else
                       ibufd(3)=-32768
                       if(ierr.eq.2) then
                          ibufd(3)=0
                       else if(0.ne.ichcm_ch(parm,1,'#')) then
                          call logit7ci(0,0,0,0,-310,'bo',0)
                       else
                          ic1=iscn_ch(ibuf,1,nchar,'#')
                          ibufd(3) = ias2b(ibuf,ic1+1,nchar-ic1)
                       endif
                       if(ibufd(3).eq.-32768) then
                          call logit7ci(0,0,0,0,-310,'bo',0)
                       else if(ioffon.eq.1) then
                          call put_buf(iclbox,ibufd,-6,'fs','tn')
                       else if(ioffon.eq.0) then
                          call put_buf(iclbox,ibufd,-6,'fs','tf')
                       endif
                    endif
                 endif
              endif
           endif
        endif
      else if (mbranch.eq.22) then
c
c if= command
c
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar = min0(ireg(2),iblen*2)
        call pchar(ibuf,nchar+1,0)
        iret=fc_if_cmd(ibuf,nchar)
        if(iret.lt.0) then
           call logit7ci(0,0,0,0,-312+iret,'bo',0)
        else if(iret.gt.0) then
           nchar=iret
           if (.not.kts) call clrcl(iclass)
           if (kts.and.klast) call cants(itscb,ntscb,5,index,indts)
           goto 320
        endif
      else if (mbranch.eq.23) then
c
c setup_proc= command
c
        ireg(2) = get_buf(iclass,ibuf,-iblen*2,idum,idum)
        nchar = min0(ireg(2),iblen*2)
        nchar = iflch(ibuf,nchar)
        ich = 1+iscn_ch(ibuf,1,nchar,'=')
        nch = trimlen(setup_proc)
        if(ich.eq.1) then
            nch = ichmv_ch(ibuf,nchar+1,'/')
            ich=min(iblen-nch+1,trimlen(setup_proc))
            call char2hol(setup_proc,ibuf,nch,nch+ich-1)
c add comma to avoid having nothing after '/' for blank
c do it always for consistency
            nch = mcoma(ibuf,nch+ich)
            call logit4(ibuf,nch-1,lsor2,lprocn)
            goto 600
        else if (ich.eq.nchar+1) then
             setup_proc=' '
             goto 600
        else if(nchar-ich+1.gt.12) then
           call logit7ci(0,0,0,0,-390,'bo',0)
        else if(ichcm_ch(ibuf,ich,setup_proc(:nch)).eq.0.and.
     &                 nchar-ich+1.eq.nch) then
             goto 600
        else
           call hol2char(ibuf,ich,nchar,setup_proc)
           nchar=nchar-ich+1
           call char2hol(setup_proc,ibuf,1,nchar)
           if (.not.kts) call clrcl(iclass)
           if (kts.and.klast) call cants(itscb,ntscb,5,index,indts)
           goto 320
        endif
      endif
      mbranch = 0
C
C     6. All working sections end up here.  Clear out class buffer (if any)
C     now, unless this is a time-scheduled command (KTS TRUE).
C     Cancel this time-scheduled command if it is the last time for it
C     (KTS TRUE and KLAST TRUE).
C     Return to time-scheduling check before suspending.
C
C if something is change here you must do it parallel for sched_init
C
600   continue
      if (.not.kts) call clrcl(iclass)
      if (kts.and.klast) call cants(itscb,ntscb,5,index,indts)
      ierr = 0
      goto 200        !  program can only be exited via terminate command.
      end
