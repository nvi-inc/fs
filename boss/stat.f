      subroutine stat(ibuf,khalt,kopblk,kskblk,icurln,idcbsk,
     .itscb,ntscb,lskd)
C
C     STAT displays current status information concerning the currently
C     running schedule on the operator's terminal
C
C  INPUT:
C
      logical kopblk,kskblk,khalt
C         - time-blocked status of operator stream
C         - time-blocked status of schedule stream
C         - HALT status of current schedule
C     ICURLN - line # of current line of schedule
      character*12 lskd
C          - 2-character name of current schedule
      dimension idcbsk(1),itscb(13,1)
C         - DCB of current schedule file
C         - time-schedule list
C     NTSCB - maximum # of items on time list
C
C  CALLING SUBROUTINES: BWORK
C
C  LOCAL VARIABLES:
C
      integer*4 irec,ioff,ir2,icurln
      integer fmpposition,fmpreadstr,fmpsetpos,fmpsetline
      integer ichcm_ch
      integer*2 ibuf(1),ib(50)
      dimension it(5)
      character*100 ibc
      character cjchar
      equivalence (ib,ibc)
C         - buffer to hold a line of schedule
C         - buffer for display output
C         - time array
C
      logical kendo,kendtp,ksto,ksttp
C         - flags, true if end of obs, end of tape, start of obs, start
C           of tape already identified
C
C  CONSTANTS:
      integer*2 lm1(40)
      character*32 lm2
C
      data lm2 /' active schedule is:            '/
C          - messages for display on terminal
C
C   DATE   WHO  CHANGES
C  840321  MWH  Created
C
C
C  1.  Initialization.
C
      kendo = .false.
      kendtp = .false.
      ksto = .false.
      ksttp = .false.
      call susp(2,2)
C
C    Print display heading.
      lm2(21:32) = lskd(1:12)
      call char2hol(lm2,lm1,1,32)
      call put_cons(lm1,32)
      call ifill_ch(ibuf,1,100,' ')
      idummy = ichmv_ch(ibuf,5,'time')
      idummy = ichmv_ch(ibuf,16,'event')
      call put_cons(ibuf,21)
      call ifill_ch(ibuf,5,4,'-')
      call ifill_ch(ibuf,16,5,'-')
      call put_cons(ibuf,21)
C
C    Get and display current time.
      call fc_rte_time(it,idum)
      call char2hol('   -  :  :',lm1,1,80)
      idummy = ib2as(it(5),lm1,1,o'41403')
      idummy = ib2as(it(4),lm1,5,o'41002')
      idummy = ib2as(it(3),lm1,8,o'41002')
      idummy = ib2as(it(2),lm1,11,o'41002')
      idummy = ichmv_ch(lm1,15,'now')
      call put_cons(lm1,18)
C
C   Save current schedule position.
      idum = fmpposition(idcbsk,ierr,irec,ioff)
C
C  2.  Main search loop.
C
      ir2 = icurln-1
      ierr = 0
      if (icurln.gt.0) idum = fmpsetline(idcbsk,ierr,ir2)
200   if(kendo.and.kendtp.and.ksto.and.ksttp) goto 300
      ilen = fmpreadstr(idcbsk,ierr,ibc)
      call char2low(ibc)
      if (ierr.lt.0) goto 500
      if(ilen.ge.0) goto 210
        call putcon_ch('end of schedule')
        goto 300
210   if(cjchar(ib,1).ne.'!') goto 220
      if(cjchar(ib,2).lt.'0'.or.cjchar(ib,2).gt.'3') goto 200
      nc = iflch(ib,ilen)
      call gttim(ib,2,nc,0,it1,it2,it3,ierr)
      idummy = ib2as(mod(it1,1024),lm1,1,o'40000'+o'1400'+3)
      idummy = ib2as(it2/60,lm1,5,o'40000'+o'1000'+2)
      idummy = ib2as(mod(it2,60),lm1,8,o'40000'+o'1000'+2)
      idummy = ib2as(it3/100,lm1,11,o'40000'+o'01000'+2)
220   if (ichcm_ch(ib,1,'et').ne.0.or.kendo) goto 230
C  End of observation
      if (ksto) then
        idummy = ichmv_ch(lm1,15,'end of next observation   ')
      else
        idummy = ichmv_ch(lm1,15,'end of current observation')
      end if
      call put_cons(lm1,41)
      kendo = .true.
      goto 200
C
230   if (ichcm_ch(ib,1,'unlod').ne.0.or.kendtp) goto 240
C  End of tape
      if (ksttp) then
        idummy = ichmv_ch(lm1,15,'end of next tape   ')
      else
        idummy = ichmv_ch(lm1,15,'end of current tape')
      end if
      call put_cons(lm1,33)
      kendtp = .true.
      goto 200
C
240   if (ichcm_ch(ib,1,'st=').ne.0) goto 200
      if (ksto) goto 250
C  Start of observation
      idummy = ichmv_ch(lm1,15,'start of next observation')
      call put_cons(lm1,40)
      ksto = .true.
C
250   if (.not.kendtp.or.ksttp) goto 200
C  Start of tape
      idummy = ichmv_ch(lm1,15,'start of next tape')
      call put_cons(lm1,32)
      ksttp = .true.
      goto 200
C
C  3.  Display HALT status.
C
300   ich = ichmv_ch(ibuf,1,'schedule is ')
      ich = 13
      if(.not.khalt)ich = ichmv_ch(ibuf,ich,'not ')
      ich = ichmv_ch(ibuf,ich,'halted')-1
      call put_cons(ibuf,ich)
C
C  4.  Display time-blocked status.
C
      ich = ichmv_ch(ibuf,1,'schedule stream is ')
      if(kskblk) goto 310
        ich = ichmv_ch(ibuf,ich,'not time-blocked')-1
        goto 340
310   continue
      ich = ichmv_ch(ibuf,ich,'time-blocked until  ')
      ind = 0
      do 320 i=1,ntscb
        if(itscb(1,i).eq.-1) goto 320
        if(cjchar(itscb(10,i),1).ne.'!') goto 320
        if(cjchar(itscb(13,i),2).ne.':') goto 320
        ind = i
320   continue
      if(ind.gt.0) goto 330
        call ifill_ch(ibuf,40,9,'?')
        ich=48
        goto 340
330   it(5) = mod(itscb(1,ind),1024)
      it(4) = itscb(2,ind)/60
      it(3) = mod(itscb(2,ind),60)
      it(2) = itscb(3,ind)/100
      idummy = ib2as(it(5),ibuf,40,o'41403')
      idummy = ichmv_ch(ibuf,43,'-')
      idummy = ib2as(it(4),ibuf,44,o'41002')
      idummy = ichmv_ch(ibuf,46,':')
      idummy = ib2as(it(3),ibuf,47,o'41002')
      idummy = ichmv_ch(ibuf,49,':')
      idummy = ib2as(it(2),ibuf,50,o'41002')
      ich=51
340   call put_cons(ibuf,ich)
      ich = ichmv_ch(ib,1,'operator stream is ')
      if(kopblk) goto 350
        ich = ichmv_ch(ib,ich,'not time-blocked')-1
        goto 370
350   ich = ichmv_ch(ib,ich,'time-blocked until  ')
      ind = 0
      do 360 i=1,ntscb
        if(itscb(1,i).eq.-1) goto 360
        if(cjchar(itscb(10,i),1).ne.'!') goto 360
        if(cjchar(itscb(13,i),2).ne.';') goto 360
        ind = i
360   continue
      if(ind.gt.0) goto 365
        call ifill_ch(ib,40,9,'?')
        ich = 48
        goto 370
365   it(5) = mod(itscb(1,ind),1024)
      it(4) = itscb(2,ind)/60
      it(3) = mod(itscb(2,ind),60)
      it(2) = itscb(3,ind)/100
      idummy = ib2as(it(5),ibuf,40,o'41403')
      idummy = ichmv_ch(ib,43,'-')
      idummy = ib2as(it(4),ibuf,44,o'41002')
      idummy = ichmv_ch(ib,46,':')
      idummy = ib2as(it(3),ibuf,47,o'41002')
      idummy = ichmv_ch(ib,49,':')
      idummy = ib2as(it(2),ibuf,50,o'41002')
      ich = 51
370   call put_cons(ib,ich)
C
C  5.  Restore schedule to original position.
C
500   idum = fmpsetpos(idcbsk,ierr,irec,ioff)
      ir2 = icurln-1
      if (icurln.gt.0) idum = fmpsetline(idcbsk,ierr,ir2)
      ilen = fmpreadstr(idcbsk,ierr,ibc)
      call char2low(ibc)
      idum = fmpsetpos(idcbsk,ierr,irec,ioff)
C
C  6.  Display current line of schedule.
C
      idummy = ichmv_ch(ibuf,1,'current line of schedule is:')
      call put_cons(ibuf,28)
      ich=ichmv_ch(ibuf,1,' #')
      icur = icurln
      nc = ib2as(icur,ibuf,ich,o'100006')
      ich = ichmv(ibuf,9,ib,1,ilen)-1
      call put_cons(ibuf,ich)
C
      return
      end
