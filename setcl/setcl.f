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
      integer*2 ibuf(40),ibuft(10),ibuf2(10),ibuf4(40)
      integer ilen,trimlen
      integer it(6),get_buf, ireg(2), fc_rte_sett,iyrctl_fs
      integer*4 centisec(2),centiavg,secs_fm,secs_fs,centifs
      integer*4 centidiff,diff,nanosec
      character*63 name
      character*6 model
      character*10 set
      character*1  cjchar
      logical rn_test
      integer idum,fc_rte_prior,rn_take
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
C
      call putpname('setcl')
      call setup_fscom
c
 1    continue
      call wait_prog('setcl',ip)
      call read_fscom
c
      set=' '
      call get_arg(1,set)
      call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &     rateti_fs,spanti_fs,modelti_fs)
      if(set.eq.'cpu') then
          call logit7ci(idum,idum,idum,-1,-3,'sc',0)
          goto 999
      else if((set.eq.'offset'.or.set.eq.'rate')
     &     .and.cjchar(modelti_fs,1).eq.'c') then
         call logit7ci(idum,idum,idum,-1,-12,'sc',0)
         goto 999
      endif
      if(set.eq.'save') then
        name=FS_ROOT//'/control/time.new'
        call fopen(9,name,ierr)
        if(ierr.ne.0) then
          write(6,91) name
91        format(' Error opening ',A/)
          call fc_exit(-1)
        endif
        call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &                       rateti_fs,spanti_fs,modelti_fs)
        if(cjchar(modelti_fs,1).eq.'r') then
          model='rate'
        else if(cjchar(modelti_fs,1).eq.'o') then
          model='offset'
        else if(cjchar(modelti_fs,1).eq.'c') then
           model='ntp'
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
      idum=fc_rte_prior(CL_PRIOR)
      nerr = 0
      call fs_get_rack(rack)
      call fs_get_rack_type(rack_type)
      call fs_get_drive(drive)
c
50    continue
      iclasm = 0
      nrec = 0
      if(drive(1).eq.S2) then
         idum=rn_take('fsctl',0)
         call fc_get_s2time(centisec,it,nanosec,ip)
         call rn_put('fsctl')
         centisec(1)=centisec(2)
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
        call fc_get_k4time(centisec,it,ip)
        centisec(2)=centisec(1)
        call rn_put('fsctl')
        if(ip(3).lt.0) then
           call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
           nerr=nerr+1
           if(nerr.le.3) goto 50
           goto 998
        endif
        goto 200
      else if (VLBA.eq.rack) then
        idum=rn_take('fsctl',0)
        call fc_get_vtime(centisec,it,ip)
        call rn_put('fsctl')
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
        call fc_get_k3time(centisec,it,ip)
        centisec(2)=centisec(1)
        call rn_put('fsctl')
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
        ireg(2) = get_buf(iclass,centisec,-8,idum,idum)
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
        ireg(2) = get_buf(iclass,centisec,-8,idum,idum)
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
        ihs = ias2b(ibuf4,ic1,nch)/10
C             The mille seconds
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
      if (abs(secs_fs-secs_fm).gt.86400*14) then
         call logit7ci(idum,idum,idum,-1,-4,'sc',0)
        goto 999
      endif
      diff=(secs_fm-secs_fs)*100+it(1)-centifs
c
      call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &                       rateti_fs,spanti_fs,modelti_fs)
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
      if (cjchar(modelti_fs,1).ne.'c'
     &     .and.(epochti_fs.eq.0.or.set.eq.'offset')) then
        inxtc=inxtc+ir2as(0.0,ibuf,inxtc,10,3)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ir2as(0.0,ibuf,inxtc,8,3)
      else
        inxtc=inxtc+ir2as(
     & (float((secs_fm-secsoffti_fs)*100+it(1)-centiavg-offsetti_fs)
     &     /(centiavg-epochti_fs))*86400.
c    &     (rateti_fs+(float(diff)/(centiavg-epochti_fs)))*86400.
     &     ,ibuf,inxtc,10,3)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ir2as((centiavg-epochti_fs)/3600e2,ibuf,inxtc,8,3)
      endif
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(diff,ibuf,inxtc,o'100000'+12)
      call logit2(ibuf,inxtc-1)
c
      inxtc=ichmv_ch(ibuf,1,'model/old,')
      inxtc=inxtc+ib2as(secsoffti_fs,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(offsetti_fs,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ib2as(epochti_fs,ibuf,inxtc,o'100000'+12)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ir2as(rateti_fs*86400.,ibuf,inxtc,8,3)
      inxtc = mcoma(ibuf,inxtc)
      inxtc=inxtc+ir2as(spanti_fs/3600e2,ibuf,inxtc,8,3)
      inxtc = mcoma(ibuf,inxtc)
      if(cjchar(modelti_fs,1).eq.'r') then
        inxtc = ichmv_ch(ibuf,inxtc,'rate')
      else if(cjchar(modelti_fs,1).eq.'o') then
        inxtc = ichmv_ch(ibuf,inxtc,'offset')
      else if(cjchar(modelti_fs,1).eq.'c') then
        inxtc = ichmv_ch(ibuf,inxtc,'ntp')
      else
        inxtc = ichmv_ch(ibuf,inxtc,'none')
      endif
      call logit2(ibuf,inxtc-1)
c
      if(cjchar(modelti_fs,1).ne.'c'.and.(set.eq.'offset'
     &       .or.(set.eq.'rate'.and.spanti_fs.le.centiavg-epochtifs)
     &       .or.(set.eq.' '.and.epochti_fs.eq.0))) then!update model
        if(set.eq.' ') set='offset'
	ierr=fc_rte_sett(secs_fm,it(1),centiavg,
     &                   set(:max(trimlen(set),1))//char(0))
        call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &                       rateti_fs,spanti_fs,modelti_fs)
        inxtc=ichmv_ch(ibuf,1,'model/new,')
        inxtc=inxtc+ib2as(secsoffti_fs,ibuf,inxtc,o'100000'+12)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ib2as(offsetti_fs,ibuf,inxtc,o'100000'+12)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ib2as(epochti_fs,ibuf,inxtc,o'100000'+12)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ir2as(rateti_fs*86400.,ibuf,inxtc,8,3)
        inxtc = mcoma(ibuf,inxtc)
        inxtc=inxtc+ir2as(spanti_fs/3600e2,ibuf,inxtc,8,3)
        inxtc = mcoma(ibuf,inxtc)
        if(cjchar(modelti_fs,1).eq.'r') then
          inxtc = ichmv_ch(ibuf,inxtc,'rate')
        else if(cjchar(modelti_fs,1).eq.'o') then
          inxtc = ichmv_ch(ibuf,inxtc,'offset')
        else
          inxtc = ichmv_ch(ibuf,inxtc,'none')
        endif
        call logit2(ibuf,inxtc-1)
c
      else if(abs(diff).gt.49) then
         call logit7ci(idum,idum,idum,-1,-13,'sc',0)
      endif
      goto 999
C
998   continue
      call logit7ci(idum,idum,idum,-1,-10,'sc',0)
999   continue
      goto 1
      end
