      subroutine lists(idcbsk,ibuf,nchar,icurln)
C
C     LISTS displays 10 lines of the current schedule on the operator's terminal
C
C  INPUT:
C
      dimension idcbsk(1)
C         - DCB of schedule file
      integer*2 ibuf(1)
C         - buffer containing entire command
C     NCHAR - number of characters in IBUF
C     ICURLN - record # of current line of schedule
C
C  CALLING SUBROUTINES: BWORK
C
C  CALLED SUBROUTINES: GTTIM,KPAST,
      logical kpast,kbreak
C
C  LOCAL VARIABLES:
C
C     IT1,IT2,IT3 - time info from GTTIM
      integer*4 ireco,ioffo,icurln
      integer fmpread,fmpposition,fmpsetpos,fmpsetline
      dimension it(5)
      integer*2 ib(53)
C         - array of time info expanded from IT1,IT2,IT3
C         - output display buffer
      character cjchar,clc1,clc2
      dimension iparm(2)
      equivalence (parm,iparm(1))
C
C  CONSTANTS:
C
      data iblen/50/
C
C  DATE  WHO  CHANGES
C 840321 MWH  Created
C
C
C  1. Initialize and determine parameter type.
C
      iline = 2
      icom = 0
      idum = fmpposition(idcbsk,ierr,ireco,ioffo)
C get current position of schedule to reposition at end 
      ieq=iscn_ch(ibuf,1,nchar,'=')
      if(ieq.eq.0.or.ieq.eq.nchar) goto 200
      ich=ieq+1
      icom=iscn_ch(ibuf,ich,nchar,',')
      ilst=nchar
      if(icom.gt.0) ilst=icom-1
      if(cjchar(ibuf,ich).eq.'#') goto 300
      if(cjchar(ibuf,ich).eq.',') goto 200
C
C  2. Handle time parameter here.
C
      call gttim(ibuf,ich,ilst,0,it1,it2,it3,ierr)
      if (ierr.lt.0) then
        call logit6c(0,0,0,0,ierr,'sp')
        goto 900
      endif
      it(5) = mod(it1,1024)
      it(4) = it2/60
      it(3) = mod(it2,60)
      it(2) = it3/100
      it(1) = 0
      idum = fmpsetpos(idcbsk,ierr,0,id)
      numln = 1
130   ilen = fmpread(idcbsk,ierr,ib,iblen*2)
      numln = numln + 1
      if (ilen.lt.0) then
        call putcon_ch('schedule ends before requested time')
        goto 900
      endif
      clc1 = cjchar(ib,1)
      clc2 = cjchar(ib,2)
      if(clc1.ne.'!'.or.clc2.lt.'0'.or.clc2.gt.'9') goto 130
cxx      idum = fmpposition(idcbsk,ierr,ireco,ioffo)
      iprvln = iline
      iline = numln
      iec=iflch(ib,ilen)
      call gttim(ib,2,iec,0,it1,it2,it3,ierr)
      if(kpast(it1,it2,it3,it)) goto 130
      idum = fmpsetline(idcbsk,ierr,iprvln-1)
      iline=iprvln-1
      goto 500
C
C  3. Handle null parameter here.

C
200   iline = max0(icurln-2,0)
      if (icurln.gt.0) idum = fmpsetline(idcbsk,ierr,iline)
      goto 500
C
C  4. Handle line # parameter here.
C
300   iline = ias2b(ibuf,ich+1,ilst-ich)
      if(iline.lt.0) goto 310
      idum = fmpsetline(idcbsk,ierr,iline)
      if(ierr.ge.0) goto 500
cxx      if(ierr.eq.0) goto 500
310     call logit7ci(0,0,0,1,-106,'bo',iline)
        goto 900
C
C  5. List requested lines of schedule.
C
500   nlines=10
      if (icom.eq.0.or.icom.eq.nchar) goto 505
      ich = icom+1
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if(ierr.eq.0.and.iparm(1).gt.0) goto 502
        call logit6c(0,0,0,0,-138,'bo')
        goto 900
502   nlines=iparm(1)
C
505   call susp(1,10)
C         -give OPRIN time to suspend
      do 520 i=iline+1,iline+nlines-1
            if(kbreak('boss ')) goto 900
        call ifill_ch(ib,1,106,' ')
        ilen = fmpread(idcbsk,ierr,ibuf,iblen*2)
        if(ilen.lt.0) then
          call putcon_ch('end of schedule')
          goto 900
        endif
        if(i.eq.icurln) idummy = ichmv_ch(ib,1,'>')
        idummy = ib2as(i,ib,2,4)
        ich = ichmv(ib,7,ibuf,1,ilen)-1
        call put_cons(ib,ich)
520   continue

900   continue 
      idum = fmpsetpos(idcbsk,ierr,ireco,ioffo)

      return
      end
