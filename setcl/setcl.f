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
      integer*2 ibuf(40),ibuft(10),ibuf2(10)
      integer*4 secs_fm,secs_bef,secs_aft,diff_bef,diff_aft,diff_avg
      integer*4 lzero
      integer fc_stime
      integer itm(13),it(6),get_buf, ireg(2)
      character*80 cbuf
      character*3 set
      logical rn_test
C
C  ROUTINES CALLED:
C
C     MATCN - to get the formatter time
C
C  LAST MODIFIED:  880509 LAR   Read formatter twice.
C                  88---- WEH   read formatter in correct order: ()
C
C     1. Get the operator's LU.
C     Set up the two buffers for MATCN and schedule it.
C
      equivalence (ihs,it(1)),(is,it(2)),(imin,it(3)),(ihr,it(4))
      equivalence (idoy,it(5)),(it(6),iyr)
      data lzero/0/,luop/6/
C
      call putpname('setcl')
      call setup_fscom
      call read_fscom
      if(.not.rn_test('fs   ')) then
        write(luop,911) 
911     format(' fs not running ')
        goto 999
      endif
      call rmpar(ip)
      nerr = 0
      set=' '
      call rcpar(1,set)
      call fs_get_rack(rack)
c
50    continue
      if(VLBA.eq.iand(rack,VLBA)) then
        call fc_get_vtime(itm(1),itm(7),it,ip)
        if(ip(3).lt.0) then
           call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
           nerr=nerr+1
           if(nerr.le.3) goto 50
           goto 998
        endif
        goto 200
      endif
        iclasm = 0
        ibuf(1) = -53
        call char2hol('fm',ibuf(2),1,2)
        call put_buf(iclasm,ibuf,-4,2Hfs,0)
        ibuf(1) = -4
        call put_buf(iclasm,ibuf,-4,2Hfs,0)
        call run_matcn(iclasm,2)
        call rmpar(ip)
        iclass = ip(1)
        ncrec = ip(2)
        ierr = ip(3)
        if(ierr.lt.0) then
          call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
        else if (iclass.ne.0.and.ncrec.eq.3) then
          goto 198
        else
          call logit7(idum,idum,idum,-1,-1,2hsc,0)
        endif
c
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
      ireg(2) = get_buf(iclass,ibuft,-20,idum,idum)
      ireg(2) = get_buf(iclass,itm,-52,idum,idum)
      ireg(2) = get_buf(iclass,ibuf,-20,idum,idum)
c
      nch = ichmv(ibuf2,1,3Htm,,1,3)
      nch = nch+ib2as(iyrctl_fs/10,ibuf2,nch,3)
      nch = ichmv(ibuf2,nch,ibuf,4,1)
C                   The last digit of the year
      nch = mcoma(ibuf2,nch)
      nch = ichmv(ibuf2,nch,ibuf,5,3)
C                   The day of the year
      nch = mcoma(ibuf2,nch)
      iyr = ias2b(ibuf,4,1) + (iyrctl_fs/10)*10   !we don't want the unit digit
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
c
200   continue
      call rte2secs(it,secs_fm)
      if(secs_fm.lt.0) then
        call logit7(idum,idum,idum,-1,-2,2hsc,0)
        nerr=nerr+1
        if(nerr.gt.2) goto 998
        goto 50
      endif
      call rte2secs(itm,secs_bef)
      if(secs_bef.lt.0) then
        call logit7(idum,idum,idum,-1,-3,2hsc,0)
        nerr=nerr+1
        if(nerr.gt.2) goto 998
        goto 50
      endif
      call rte2secs(itm(7),secs_aft)
      if(secs_aft.lt.0) then
        call logit7(idum,idum,idum,-1,-4,2hsc,0)
        nerr=nerr+1
        if(nerr.gt.2) goto 998
        goto 50
      endif
C
C*****************THE REAL THING*******************
C
C     diff_bef=(secs_fm-secs_bef)*100+it(1)-itm(1)
      diff_aft=(secs_fm-secs_aft)*100+it(1)-itm(7)
C     diff_avg=(diff_bef+diff_aft)/2
      if(set.eq.'set') then
        ierr=fc_stime(secs_fm)
        call fs_set_time_index(0)
        call fs_set_time_offset(lzero,0)
        call fs_set_time_offset(lzero,1)
        if (ierr.ne.0) then
          call logit7(idum,idum,idum,-1,-5,2hsc,0)
          nerr = nerr+1
          if (nerr.gt.2) goto 998
          goto 50
        endif
        set=' '   !everything worked, now read the offset
        nerr=0
        goto 50
      else                                    !update offset in common
        call fs_get_time_index(time_index)
        time_index=iand(time_index,1)
        call fs_get_time_offset(time_offset(time_index+1),time_index)
        time_offset(2-time_index)=time_offset(time_index+1)+diff_aft
        time_index=1-time_index
        call fs_set_time_offset(time_offset(time_index+1),time_index)
        call fs_set_time_index(time_index)
      endif
      write(cbuf,1991) time_offset(time_index+1),diff_aft
1991  format('fm-cpu time difference ',i10,' (0.01 secs), change ',i10)
      call char2hol(cbuf,ibuf,1,64)
      call logit2(ibuf,64)
      write(cbuf,1992) (itm(iweh),iweh=1,6)
1992  format(' it1',6i10)
      call char2hol(cbuf,ibuf,1,64)
      call logit2(ibuf,64)
      write(cbuf,1993) (itm(iweh),iweh=7,12)
1993  format(' it2',6i10)
      call char2hol(cbuf,ibuf,1,64)
      call logit2(ibuf,64)
      write(cbuf,1994) (it(iweh),iweh=1,6)
1994  format(' it ',6i10)
      call char2hol(cbuf,ibuf,1,64)
      call logit2(ibuf,64)
      goto 999
C
998   continue
      call logit7(idum,idum,idum,-1,-10,2hsc,0)
999   continue
      end
