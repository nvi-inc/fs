      program setcl
C 
C     This program reads the formatter to get the 
C     correct time and then sets the computer clock.
C 
C************************************************************ 
C 
C     **NOTE** THE MARK III FIELD SYSTEM MUST BE UP
C              AND RUNNING TO USE THIS PROGRAM.
C
C     CAUTION: THIS PROGRAM SHOULD BE RUN *ONLY* DURING
C     REALLY QUIESCENT PERIODS OF SYSTEM OPERATION.
C     MAKE SURE THAT NO PROGRAMS ON THE TIME LIST
C     WILL HAVE THEIR EXECUTION TIMES FOREVER IN THE
C     PAST WHEN THE TIME IS UPDATED.
C
C************************************************************
      include '../include/fscom.i'
C
C  INPUT:
C
      integer*4 ip(5)
C      - IP(1) = lu for error messages
C
C  LOCAL:
C
      integer*2 ibuf(120),ibuft(10),ibuf2(10),ibuf4(40)
      integer ilen,trimlen,fc_get_vtime,fc_get_s2time,fc_get_5btime
      integer it(6),get_buf, ireg(2), fc_rte_sett,iyrctl_fs
      integer fc_dad_pid
      integer*4 centiavg,secs_fm,secs_fs,centifs
      integer*4 centidiff,diff,nanosec
      integer*4 diffunix,unixdiff,difffs2unix
      character*63 name
      character*13 m5sync,m5pps,m5freq,m5clock
      character*6 model
      character*10 set
      character*1  cjchar
      logical rn_test,kfm
      integer idum,fc_rte_prior,rn_take,fc_ntp_synch,ntp_synch
c
      include '../include/time_arrays.i'
C
C  ROUTINES CALLED:
C
C     MATCN - to get the formatter time
C
C  LAST MODIFIED:  880509 LAR   Read formatter twice.
C                  88---- WEH   read formatter in correct order: ()
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920716  Added logic to use the Mark IV formatter to get the time.
C
C     1. Get the operator's LU.
C     Set up the two buffers for MATCN and schedule it.
C
      equivalence (ihs,it(1)),(is,it(2)),(imin,it(3)),(ihr,it(4))
      equivalence (idoy,it(5)),(it(6),iyr)
      data luop/6/
      data ilen/40/
      data ibase/0/,ibaseold/0/,ierrors/1/
C
      call putpname('setcl')
      call setup_fscom
      if(0.ne.rn_take('setcl',1)) then
        call logit7ci(idum,idum,idum,-1,-18,'sc',0)
        return
      endif
c
 1    continue
      call wait_prog('setcl',ip)
      call read_fscom
c
      kfm=.true.
      set=' '
      call get_arg(1,set)
      call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &     rateti_fs,spanti_fs,modelti_fs,icomputer)
      if(set.eq.'cpu') then
          call logit7ci(idum,idum,idum,-1,-3,'sc',0)
          goto 999
      endif
      if(set.eq.'save') then
        name=FS_ROOT//'/control/time.new'
        call fopen(9,name,ierr)
        if(ierr.ne.0) then
           call put_stderr('Error opening  '//char(0))
           call put_stderr(name//char(0))
           call put_stderr('\n'//char(0))
          call fc_exit(-1)
        endif
        call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &       rateti_fs,spanti_fs,modelti_fs,icomputer)
        if(cjchar(modelti_fs,1).eq.'r') then
          model='rate'
        else if(cjchar(modelti_fs,1).eq.'o') then
          model='offset'
        else if(cjchar(modelti_fs,1).eq.'c') then
           model='computer'
        else
          model='none'
        endif
        write(9,191) rateti_fs*86400.,spanti_fs/3600e2,
     &               model(:trimlen(model))
191     format(
     &   '*     rate (seconds/day)   span (hours)   model ',
     &   '(none/offset/rate)'/
     &   '      ',f8.3,'             ',f8.3,'       ',a)
        endfile(9)
        close(9)
        goto 999
      endif
c
      if(.not.rn_test('fs   ')) then
        write(luop,911) 
911     format(' fs not running ')
        goto 999
      endif
      
      if(index("+-0123456789",set(1:1)).eq.0) goto 49
      if(((set(2:2).eq.'0'.and.index("+-",set(1:1)).ne.0)
     &     .or.set(1:1).eq.'0').and.set(1:2).ne.'0 ') then
         call logit7ci(idum,idum,idum,-1,-16,'sc',0)
         goto 999
      endif
      do i=2,trimlen(set)
         if(index("0123456789",set(i:i)).eq.0) goto 49
      enddo
      read(set,*) ibase
      ibase=100*((ibase+sign(50,ibase))/100)
      set=' '

 49   continue
      if(set.ne." ".and.set.ne."offset".and.set.ne."rate"
     &     .and.set.ne."adapt".and.set.ne."computer"
     &     .and.set.ne."fs".and.set.ne."s2das") then
         call logit7ci(idum,idum,idum,-1,-17,'sc',0)
         goto 999
      endif

      idum=fc_rte_prior(CL_PRIOR)
      nerr = 0
      call fs_get_rack(rack)
      call fs_get_rack_type(rack_type)
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
c
50    continue

      iclasm = 0
      nrec = 0
      if (MK5.eq.drive(1).and.
     &     (MK5B.eq.drive_type(1).or.MK5b_BS.eq.drive_type(1))) then
        idum=rn_take('fsctl',0)
        idum=fc_get_5btime(centisec,it,ip,0,m5sync,m5pps,m5freq,m5clock)
        call rn_put('fsctl')
c       write(6,*) 'centisec ',centisec(1),centisec(2),
c    &       centisec(2)-centisec(1)
c       write(6,*) 'unixsec  ',unixsec(1),unixsec(2)
c       write(6,*) 'unixhs   ',unixhs(1),unixhs(2)
c       write(6,*) 'm5sync  ',m5sync
c       write(6,*) 'm5pps   ',m5pps 
c       write(6,*) 'm5freq  ',m5freq
c       write(6,*) 'm5clock ',m5clock
        centisec(2)=centisec(1)
        unixsec(2)=unixsec(1)
        unixhs(2)=unixhs(1)
        if(ip(3).lt.0) then
           call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
           nerr=nerr+1
           if(nerr.le.3) goto 50
           goto 998
        endif
        goto 200
      else if(drive(1).eq.S2.or.set.eq."s2das".or.rack.eq.S2) then
         idum=rn_take('fsctl',0)
         if(set.ne."s2das".and.drive(1).eq.S2) then
            idum=fc_get_s2time("r1"//char(0),centisec,it,nanosec,ip,0)
         else
            idum=fc_get_s2time("da"//char(0),centisec,it,nanosec,ip,0)
         endif
         call rn_put('fsctl')
         centisec(1)=centisec(2)
         unixsec(1)=unixsec(2)
         unixhs(1)=unixhs(2)
         if(ip(3).lt.0) then
            if(ip(3).lt.-400.and.ip(3).gt.-404) then
               call char2hol('sc',ip(4),1,2)
            endif
            call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
            nerr=nerr+1
            if(nerr.le.3) goto 50
            goto 998
         endif
         goto 200
      else if(K4.eq.drive(1) ) then
        idum=rn_take('fsctl',0)
        call fc_rte_cmpt(unixsec(1),unixhs(1))
        call fc_get_k4time(centisec,it,ip)
        call fc_rte_cmpt(unixsec(2),unixhs(2))
        call rn_put('fsctl')
        centisec(2)=centisec(1)
        unixsec(2)=unixsec(1)
        unixhs(2)=unixhs(1)
        if(ip(3).lt.0) then
           call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
           nerr=nerr+1
           if(nerr.le.3) goto 50
           goto 998
        endif
        goto 200
      else if (VLBA.eq.rack) then
        idum=rn_take('fsctl',0)
        idum=fc_get_vtime(centisec,it,ip,0)
        call rn_put('fsctl')
        centisec(2)=centisec(1)
        unixsec(2)=unixsec(1)
        unixhs(2)=unixhs(1)
        if(ip(3).lt.0) then
           call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
           nerr=nerr+1
           if(nerr.le.3) goto 50
           goto 998
        endif
        goto 200
      else if (MK4.eq.rack.or.VLBA4.eq.rack.or.rack.eq.K4MK4) then
        ibuf(1) = -54
        idum = ichmv_ch(ibuf,3,'fm')
        idum = ichmv_ch(ibuf,5,'/TIM')
C                   Place MAT address and command for the formatter 
C                   into buffer
        nch = 8
        nrec = nrec + 1
        call put_buf(iclasm,ibuf,-nch,'fs','  ')
C             two return buffers with imode = -54
      else if(MK3.eq.rack) then   ! Mark III formatter
        ibuf(1) = -53
        call char2hol('fm',ibuf(2),1,2)
        nrec = nrec + 1
        call put_buf(iclasm,ibuf,-4,'fs','  ')  
C             two return buffers with imode = -53
        ibuf(1) = -4
        nrec = nrec + 1
        call put_buf(iclasm,ibuf,-4,'fs','  ')
      else if(K4K3.eq.rack) then
        idum=rn_take('fsctl',0)
        call fc_rte_cmpt(unixsec(1),unixhs(1))
        call fc_get_k3time(centisec,it,ip)
        call fc_rte_cmpt(unixsec(2),unixhs(2))
        call rn_put('fsctl')
        centisec(2)=centisec(1)
        unixsec(2)=unixsec(1)
        unixhs(2)=unixhs(1)
        if(ip(3).lt.0) then
           call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
           nerr=nerr+1
           if(nerr.le.3) goto 50
           goto 998
        endif
        goto 200
      else
         call logit7ci(idum,idum,idum,-1,-11,'sc',0)
         goto 1
      endif
C
      idum=rn_take('fsctl',0)
      call run_matcn(iclasm,nrec)
      call rn_put('fsctl')
      call rmpar(ip)
      iclass = ip(1)
      ncrec = ip(2)
      ierr = ip(3)
      if(ierr.lt.0) then
        call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
      else if (iclass.ne.0.and.ncrec.eq.nrec+1) then
        goto 198
      else
        call logit7ci(idum,idum,idum,-1,-1,'sc',0)
      endif
C
      if (iclass.ne.0.and.ncrec.ne.0) then
        do i=1,ncrec
          ireg(2) = get_buf(iclass,ibuf,-20,idum,idum)
        enddo
      endif
      nerr = nerr + 1
      if (nerr.le.2) goto 50
      goto 998

C
C
C     2. Get back the first buffer from MATCN, with the yddd.
C     Fill in the year and date in the output buffer.
C     Get back the second buffer and fill in the hms.
C     The message we are formatting for the system is:
C         TM,yyyy,ddd,hh,mm,ss
C
198   continue
      if (MK3.eq.rack) then
        call ifill_ch(ibuft,1,20,' ')
        call ifill_ch(ibuf ,1,20,' ')
        ireg(2) = get_buf(iclass,ibuft,-20,idum,idum)
        ireg(2) = get_buf(iclass,centisec,-24,idum,idum)
        ireg(2) = get_buf(iclass,ibuf,-20,idum,idum)
c
        nch = ichmv_ch(ibuf2,1,'tm,')

        idigyr=ias2b(ibuf,4,1)
        call fc_rte_time(it,it(6))
        if(mod(it(6),10).eq.0.and.idigyr.eq.9) then
           iyrctl_fs=it(6)-10-mod(it(6),10)
        else if(mod(it(6),10).eq.9.and.idigyr.eq.0) then
           iyrctl_fs=it(6)+10-mod(it(6),10)
        else
           iyrctl_fs=it(6)-mod(it(6),10)
        endif
c
        nch = nch+ib2as(iyrctl_fs/10,ibuf2,nch,3)
        nch = ichmv(ibuf2,nch,ibuf,4,1)
C                   The last digit of the year
        nch = mcoma(ibuf2,nch)
        nch = ichmv(ibuf2,nch,ibuf,5,3)
C                   The day of the year
        nch = mcoma(ibuf2,nch)
        iyr = ias2b(ibuf,4,1) + (iyrctl_fs/10)*10   
C                      we don't want the unit digit
        idoy = ias2b(ibuf,5,3)
        idum=ichmv(ibuf,1,ibuft,1,20)
        nch = ichmv(ibuf2,nch,ibuf,3,2)
C                   The hours
        nch = mcoma(ibuf2,nch)
        nch = ichmv(ibuf2,nch,ibuf,5,2)
C                   Minutes
        nch = mcoma(ibuf2,nch)
        ihr = ias2b(ibuf,3,2)
        imin = ias2b(ibuf,5,2)
        is = ias2b(ibuf,7,2)
        ihs = ias2b(ibuf,9,2)
      else   ! MK4
C  Expect the return buffer from the Mark IV formatter to look like
C   1992 198 16:17:34.777
        call ifill_ch(ibuf4,1,ilen,' ')
        ireg(2) = get_buf(iclass,ibuf4,-ilen,idum,idum)
        nchar=min0(ireg(2),ilen)
        ireg(2) = get_buf(iclass,centisec,-24,idum,idum)
        centisec(2)=centisec(1)
        unixsec(2)=unixsec(1)
        unixhs(2)=unixhs(1)
        ich=3
        call gtfld(ibuf4,ich,nchar,ic1,ic2)
        if(ic1.ge.ic2) then
           call logit7ci(idum,idum,idum,-1,-5,'sc',0)
           nerr=nerr+1
           if(nerr.gt.2) goto 998
           goto 50
        endif
        nch = ic2-ic1+1
        iyr = ias2b(ibuf4,ic1,nch)
C                   The year
        ich = ic2+1
        call gtfld(ibuf4,ich,nchar,ic1,ic2)
        if(ic1.ge.ic2) then
           call logit7ci(idum,idum,idum,-1,-5,'sc',0)
           nerr=nerr+1
           if(nerr.gt.2) goto 998
           goto 50
        endif
        nch=ic2-ic1+1
        idoy = ias2b(ibuf4,ic1,nch)
C              The Day Of the Year      
        ich = ic2+1
        call gtfld(ibuf4,ich,nchar,ic1,ic2)
        if(ic1.ge.ic2) then
           call logit7ci(idum,idum,idum,-1,-5,'sc',0)
           nerr=nerr+1
           if(nerr.gt.2) goto 998
           goto 50
        endif
        nch=ic2-ic1+1
        ic3=iscn_ch(ibuf4,ic1,ic2,':')
        nch = ic3-ic1
        ihr = ias2b(ibuf4,ic1,nch)
C             The Hour 
        ic1=ic3+1
        ic3=iscn_ch(ibuf4,ic1,ic2,':')
        nch = ic3-ic1
        imin = ias2b(ibuf4,ic1,nch)
C              The Minutes
        ic1=ic3+1
        ic3=iscn_ch(ibuf4,ic1,ic2,'.')
        nch = ic3-ic1
        is = ias2b(ibuf4,ic1,nch)
C            The Seconds
        ic1=ic3+1
        nch = ic2-ic1+1
        ihs = (ias2b(ibuf4,ic1,nch)+5)/10
C             The mille seconds
        if(ihs.gt.99) then
           ihs=ihs-100
           call fc_rte2secs(it,secs_fm)
           secs_fm=secs_fm+1
           call fc_secs2rte(secs_fm,it)
        endif
      endif
C
200   continue
      call fc_rte2secs(it,secs_fm)
      if(secs_fm.lt.0.or.it(1).lt.0) then
        call logit7ci(idum,idum,idum,-1,-2,'sc',0)
        nerr=nerr+1
        if(nerr.gt.2) goto 998
        goto 50
      endif
C
C*****************THE REAL THING*******************
C
      centidiff=centisec(2)-centisec(1)
      centiavg=centisec(1)+centidiff/2
c
      centifs=centiavg
      call fc_rte_fixt(secs_fs,centifs)
      diff=(secs_fm-secs_fs)*100+it(1)-centifs
c
 201  continue
      unixdiff=unixsec(2)-unixsec(1)
      unixdiff=unixdiff*100+unixhs(2)-unixhs(1)
      unixhs(1)=unixhs(1)+unixdiff/2
      unixsec(1)=unixsec(1)+unixhs(1)/100
      unixhs(1)=mod(unixhs(1),100)
c
      call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &     rateti_fs,spanti_fs,modelti_fs,icomputer)
c
      if (kfm.and.cjchar(modelti_fs,1).ne.'c') then
         call fc_rte_check(iErr)
         if(iErr.eq.-5) then
            call logit7ci(idum,idum,idum,-1,-25,'sc',0)
         else if(iErr.ne.0) then
            call logit7ci(idum,idum,idum,-1,-5+iErr,'sc',0)
         endif
         if(abs(dble(secsoffti_fs)-dble(secs_fm)).gt.86400*248) then
            call logit7ci(idum,idum,idum,-1,-4,'sc',0)
            goto 999
         endif
      endif
c
      diffunix=(secs_fm-unixsec(1))*100+it(1)-unixhs(1)
      difffs2unix=(secs_fs-unixsec(1))*100+centifs-unixhs(1)
      if(epochti_fs.eq.0.or.cjchar(modelti_fs,1).eq.'c'
     &     .or.icomputer.ne.0) then
         diff=diffunix
         difffs2unix=0
      endif
c
      inxtc=ichmv_ch(ibuf,1,'time/')
      inxtc=inxtc+ib2as(centiavg,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(centidiff,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(it(6),ibuf,inxtc,o'40000'+o'400'*4+4)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(it(5),ibuf,inxtc,o'40000'+o'400'*3+3)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(it(4),ibuf,inxtc,o'40000'+o'400'*2+2)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(it(3),ibuf,inxtc,o'40000'+o'400'*2+2)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(it(2),ibuf,inxtc,o'40000'+o'400'*2+2)
      inxtc=ichmv_ch(ibuf,inxtc,'.')
      inxtc=inxtc+ib2as(it(1),ibuf,inxtc,o'40000'+o'400'*2+2)
      inxtc = mcoma(ibuf,inxtc)
      if ((.not.kfm).or.epochti_fs.eq.0.or.icomputer.ne.0
     &     .or.cjchar(modelti_fs,1).eq.'c') then
        inxtc=inxtc+ir2as(0.0,ibuf,inxtc,10,3)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ir2as(0.0,ibuf,inxtc,8,3)
      else
        inxtc=inxtc+ir2as(
     & (float((secs_fm-secsoffti_fs)*100+it(1)-centiavg-offsetti_fs
     &        -ibase)
     &     /(centiavg-epochti_fs))*86400.
c    &     (rateti_fs+(float(diff)/(centiavg-epochti_fs)))*86400.
     &     ,ibuf,inxtc,10,3)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ir2as((centiavg-epochti_fs)/3600e2,ibuf,inxtc,8,3)
      endif
      inxtc = mcoma(ibuf,inxtc)
      if(kfm) then
         inxtc=inxtc+ib2as(diff,ibuf,inxtc,o'100000'+12)
      else
         inxtc=ichmv_ch(ibuf,inxtc,'$$$$$$$$$$$$')
      endif
      call logit2(ibuf,inxtc-1)
c
      ntp_synch=fc_ntp_synch(ierrors)
      if(ntp_synch.lt.0) ierrors=0
      inxtc=ichmv_ch(ibuf,1,'model/old,')
      inxtc=inxtc+ib2as(secsoffti_fs,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(offsetti_fs,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      if(epochti_fs.eq.0.or.cjchar(modelti_fs,1).eq.'c'
     &     .or.icomputer.ne.0) then
         inxtc=inxtc+ib2as(0,ibuf,inxtc,o'100000'+12)
      else
         inxtc=inxtc+ib2as(epochti_fs,ibuf,inxtc,o'100000'+12)
      endif
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ir2as(rateti_fs*86400.,ibuf,inxtc,8,3)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ir2as(spanti_fs/3600e2,ibuf,inxtc,8,3)
      inxtc = mcoma(ibuf,inxtc)
      if(epochti_fs.eq.0.or.cjchar(modelti_fs,1).eq.'c'
     &     .or.icomputer.ne.0) then
        inxtc = ichmv_ch(ibuf,inxtc,'computer,')
      else if(cjchar(modelti_fs,1).eq.'r') then
        inxtc = ichmv_ch(ibuf,inxtc,'rate,')
      else if(cjchar(modelti_fs,1).eq.'o') then
        inxtc = ichmv_ch(ibuf,inxtc,'offset,')
      else
         inxtc = ichmv_ch(ibuf,inxtc,'none,')
      endif
      inxtc=inxtc+ib2as(ibaseold,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      if(ntp_synch.eq.1) then
         inxtc = ichmv_ch(ibuf,inxtc,'sync,')
      else if(ntp_synch.eq.0) then
         inxtc = ichmv_ch(ibuf,inxtc,'no_sync,')
      else
         inxtc = ichmv_ch(ibuf,inxtc,'unknown,')
      endif
      inxtc=inxtc+ib2as(difffs2unix,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      if(kfm) then
         inxtc=inxtc+ib2as(diffunix,ibuf,inxtc,o'100000'+12)
      else
         inxtc=ichmv_ch(ibuf,inxtc,'$$$$$$$$$$$$')
      endif
      call logit2(ibuf,inxtc-1)
c
      if(set.eq.'fs'.or.ibaseold.ne.ibase.or.set.eq.'computer'
     &     .or.(kfm
     &     .and.((set.eq.'offset'.and.icomputer.eq.0)
     &     .or.(set.eq.'rate'.and.spanti_fs.le.centiavg-epochti_fs
     &          .and.epochti_fs.ne.0.and.icomputer.eq.0
     &          .and.cjchar(modelti_fs,1).eq.'r')
     &     .or.(set.eq.'adapt'.and.cjchar(modelti_fs,1).eq.'r'
     &          .and.abs(diff-ibase).le.50.and.epochti_fs.ne.0
     &          .and.(centiavg-epochti_fs.gt.360000
     &                .or.spanti_fs.le.centiavg-epochti_fs))
     &       .or.(set.eq.' '.and.epochti_fs.eq.0
     &     .and.icomputer.eq.0)))) then            !update model
        if(set.eq.' ') set='offset'
        if(ibase.ne.ibaseold) then
           ibaseold=ibase
        else if(set.eq.'fs') then
           call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &          rateti_fs,spanti_fs,modelti_fs,icomputer)
           if(icomputer.eq.0) goto 999
           icomputer=0
           call fs_set_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &          rateti_fs,spanti_fs,modelti_fs,icomputer)
        else if(set.eq."computer") then
           call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &          rateti_fs,spanti_fs,modelti_fs,icomputer)
           if(icomputer.ne.0) goto 999
           icomputer=1
           call fs_set_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &          rateti_fs,spanti_fs,modelti_fs,icomputer)
        else
           if(set.ne."offset") then
              it(1)=it(1)-ibase
              if(it(1).gt.0) then
                 secs_fm=secs_fm+it(1)/100
                 it(1)=mod(it(1),100)
              else if(it(1).lt.0) then
                 secs_fm=secs_fm+(it(1)-99)/100
                 it(1)=mod(100+mod(it(1),100),100)
              endif
           else
              ibase=0
              ibaseold=ibase
           endif
           ierr=fc_rte_sett(secs_fm,it(1),centiavg,
     &          set(:max(trimlen(set),1))//char(0))
           call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &          rateti_fs,spanti_fs,modelti_fs,icomputer)
        endif
        inxtc=ichmv_ch(ibuf,1,'model/new,')
        inxtc=inxtc+ib2as(secsoffti_fs,ibuf,inxtc,o'100000'+12)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ib2as(offsetti_fs,ibuf,inxtc,o'100000'+12)
        inxtc = mcoma(ibuf,inxtc)
        if(epochti_fs.eq.0.or.cjchar(modelti_fs,1).eq.'c'
     &       .or.icomputer.ne.0) then
           inxtc=inxtc+ib2as(0,ibuf,inxtc,o'100000'+12)
        else
           inxtc=inxtc+ib2as(epochti_fs,ibuf,inxtc,o'100000'+12)
        endif
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ir2as(rateti_fs*86400.,ibuf,inxtc,8,3)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ir2as(spanti_fs/3600e2,ibuf,inxtc,8,3)
        inxtc = mcoma(ibuf,inxtc)
        if(epochti_fs.eq.0.or.cjchar(modelti_fs,1).eq.'c'
     &       .or.icomputer.ne.0) then
           inxtc = ichmv_ch(ibuf,inxtc,'computer')
        else if(cjchar(modelti_fs,1).eq.'r') then
          inxtc = ichmv_ch(ibuf,inxtc,'rate')
        else if(cjchar(modelti_fs,1).eq.'o') then
           inxtc = ichmv_ch(ibuf,inxtc,'offset')
        else
           inxtc = ichmv_ch(ibuf,inxtc,'none')
        endif
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ib2as(ibase,ibuf,inxtc,o'100000'+12)
        call logit2(ibuf,inxtc-1)
c
      else if(kfm.and.abs(diff-ibase).gt.50) then
         call logit7ci(idum,idum,idum,-1,-13,'sc',0)
      else if(.not.kfm) then
         call logit7ci(idum,idum,idum,-1,-10,'sc',0)
         if(abs(difffs2unix).gt.50) then
            call logit7ci(idum,idum,idum,-1,-12,'sc',0)
         endif
         if(ntp_synch.eq.0) then
            call logit7ci(idum,idum,idum,-1,-14,'sc',0)
         else if(ntp_synch.ne.1) then
            call logit7ci(idum,idum,idum,-1,-15,'sc',0)
         endif
         goto 1
      endif
      goto 999
C
998   continue
      kfm=.false.
      goto 201
999   continue
      if (MK5.eq.drive(1).and.
     &     (MK5B.eq.drive_type(1).or.MK5B_BS.eq.drive_type(1))) then
        if((MK4.eq.rack.and.MK45.eq.rack_type).or.
     &       (VLBA4.eq.rack.and.VLBA45.eq.rack_type)) then
           if("vsi"//char(0).ne.m5pps(1:4)) then
              call logit7ci(idum,idum,idum,-1,-19,'sc',0)
           endif
           if("32"//char(0).ne.m5freq(1:3)) then
              call logit7ci(idum,idum,idum,-1,-20,'sc',0)
           endif
           if("ext"//char(0).ne.m5clock(1:4)) then
              call logit7ci(idum,idum,idum,-1,-21,'sc',0)
           endif
        else
           if("ext"//char(0).ne.m5clock(1:4)) then
              call logit7ci(idum,idum,idum,-1,-22,'sc',0)
           endif
        endif
        if("not_synced"//char(0).eq.m5sync(1:11)) then
           call logit7ci(idum,idum,idum,-1,-23,'sc',0)
        elseif("syncerr_gt_3"//char(0).eq.m5sync(1:13)) then
           call logit7ci(idum,idum,idum,-1,-24,'sc',0)
        endif
      endif
      goto 1
      end
