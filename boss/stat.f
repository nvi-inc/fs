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
      integer*4 irec,ioff,ir2,io2,icurln
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
      dimension lm1(20)
      character*32 lm2
C
      data iblen /50/
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
      call ifill_ch(lm1,1,80,' ')
      lm2(21:32) = lskd(1:12)
      call put_cons(lm2,32)
      call ifill_ch(ibuf,1,100,' ')
      idummy = ichmv(ibuf,5,4htime,1,4)
      idummy = ichmv(ibuf,16,5hevent,1,5)
      call put_cons(ibuf,21)
      call ifill_ch(ibuf,5,4,'-')
      call ifill_ch(ibuf,16,5,'-')
      call put_cons(ibuf,21)
C
C    Get and display current time.
      call fc_rte_time(it,idum)
      call char2hol('   -  :  :',lm1,1,10)
      idummy = ib2as(it(5),lm1,1,o'41403')
      idummy = ib2as(it(4),lm1,5,o'41002')
      idummy = ib2as(it(3),lm1,8,o'41002')
      idummy = ib2as(it(2),lm1,11,o'41002')
      idummy = ichmv(lm1,15,3hnow,1,3)
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
      idummy = ib2as(it3/100,lm1,11,o'40000'+o'0100'+2)
220   if (ichcm_ch(ib,1,'et').ne.0.or.kendo) goto 230
C  End of observation
      if (ksto) then
        idummy = ichmv(lm1,15,26hend of next observation   ,1,26)
      else
        idummy = ichmv(lm1,15,26hend of current observation,1,26)
      end if
      call put_cons(lm1,41)
      kendo = .true.
      goto 200
C
230   if (ichcm_ch(ib,1,'unlod').ne.0.or.kendtp) goto 240
C  End of tape
      if (ksttp) then
        idummy = ichmv(lm1,15,19hend of next tape   ,1,19)
      else
        idummy = ichmv(lm1,15,19hend of current tape,1,19)
      end if
      call put_cons(lm1,33)
      kendtp = .true.
      goto 200
C
240   if (ichcm_ch(ib,1,'st=').ne.0) goto 200
      if (ksto) goto 250
C  Start of observation
      idummy = ichmv(lm1,15,25hstart of next observation,1,25)
      call put_cons(lm1,40)
      ksto = .true.
C
250   if (.not.kendtp.or.ksttp) goto 200
C  Start of tape
      idummy = ichmv(lm1,15,18hstart of next tape,1,18)
      call put_cons(lm1,32)
      ksttp = .true.
      goto 200
C
C  3.  Display HALT status.
C
300   ich = ichmv(ibuf,1,12hschedule is ,1,12)
      ich = 13
      if(.not.khalt)ich = ichmv(ibuf,ich,4hnot ,1,4)
      ich = ichmv(ibuf,ich,6hhalted,1,6)-1
      call put_cons(ibuf,ich)
C
C  4.  Display time-blocked status.
C
      ich = ichmv(ibuf,1,19hschedule stream is ,1,19)
      if(kskblk) goto 310
        ich = ichmv(ibuf,ich,16hnot time-blocked,1,16)-1
        goto 340
310   continue
      ich = ichmv(ibuf,ich,20htime-blocked until  ,1,20)
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
      idummy = ichmv(ibuf,43,2h- ,1,1)
      idummy = ib2as(it(4),ibuf,44,o'41002')
      idummy = ichmv(ibuf,46,2h: ,1,1)
      idummy = ib2as(it(3),ibuf,47,o'41002')
      idummy = ichmv(ibuf,49,2h: ,1,1)
      idummy = ib2as(it(2),ibuf,50,o'41002')
      ich=51
340   call put_cons(ibuf,ich)
      ich = ichmv(ib,1,19hoperator stream is ,1,19)
      if(kopblk) goto 350
        ich = ichmv(ib,ich,16hnot time-blocked,1,16)-1
        goto 370
350   ich = ichmv(ib,ich,20htime-blocked until  ,1,20)
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
      idummy = ichmv(ib,43,2h- ,1,1)
      idummy = ib2as(it(4),ibuf,44,o'41002')
      idummy = ichmv(ib,46,2h: ,1,1)
      idummy = ib2as(it(3),ibuf,47,o'41002')
      idummy = ichmv(ib,49,2h: ,1,1)
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
      idummy = ichmv(ibuf,1,28hcurrent line of schedule is:,1,28)
      call put_cons(ibuf,28)
      ich=ichmv(ibuf,1,2h #,1,2)
      icur = icurln
      nc = ib2as(icur,ibuf,ich,o'100006')
      ich = ichmv(ibuf,9,ib,1,ilen)-1
      call put_cons(ibuf,ich)
C
      return
      end
