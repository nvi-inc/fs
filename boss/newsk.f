      subroutine newsk(ibuf,ic1,nchar,idcbsk,iblen,ierr,
     .icurln,ilstln)
C
C  NEWSK handles the starting of a new schedule for BOSS
C
C  INPUT:
C
C     IBUF - input buffer with command and parameters
C     NCHAR - number of characters in IBUF (i.e. last char)
C     IC1 - first character of the field we are to process
C     IDCBSK - schedule file DCB, already opened OK
C     IBLEN - available length of IBUF
      integer*2 ibuf(1)
      integer idcbsk(1)
C
C  COMMON:
C
      include '../include/fscom.i'
      include 'bosscm.i'
C
C
C  LOCAL:
C
      integer*4 irec,ioff,irec2,id,icurln,ilstln
      integer fmpposition,fmpreadstr,fmpsetpos,fmpsetline
      integer ichcm_ch
      logical kpast,ktime
      dimension it(5)
      integer*2 ib(50)
      character*100 ibc
      character cjchar
      equivalence (ib,ibc)
      data  ibl/50/
C
C  First check 1st line of schedule for experiment name and year
      irecln = 1
      ilen = fmpreadstr(idcbsk,ierr,ibc)
      irecln = irecln + 1
      call char2low(ibc)
      if(ilen.le.0) then
        ierr = -1
        goto 100
      endif
      if(cjchar(ib,1).ne.'"') goto 100
      nch = 2
C  If 1st line is a comment, get experiment name here
      call gtfld(ib,nch,ibl*2,icf,ic2)
      if(icf.eq.0) goto 100
      nc = min0(8,ic2-icf+1)
      lexper=' '
      call ifill_ch(ilexper,1,8,' ')
      idummy = ichmv(ilexper,1,ib,icf,nc)
      call hol2char(ilexper,1,8,lexper)
      call fs_set_lexper(ilexper)
C  Now get the year of the schedule
      call gtfld(ib,nch,ibl*2,icf,ic2)
      if(icf.eq.0) goto 100
      nc = min0(4,ic2-icf+1)
      iy = ias2b(ib,icf,nc)
      if(iy.lt.0) goto 100
      if(iy.lt.100) iy = iy+1900
C  Make sure schedule year is same as current year
      call fc_rte_time(it,iyr)
      if(iy.ne.iyr) then
        call logit6(0,0,0,0,-137,2hbo)
        ierr = -1
        goto 900
      endif
      iyear = iy
C
100   idum = fmpsetpos(idcbsk,ierr,0,id)
      irecln = 1 
      ilstln=100000
      nlines=0
      ic2=iscn_ch(ibuf,ic1,nchar,',')+1
      if(ic2.eq.1) ic2=nchar+2
      if(ic2.gt.nchar) goto 105
      nlines=ias2b(ibuf,ic2,nchar-ic2+1)
      if(nlines.ge.0) goto 105
        call logit6(0,0,0,0,-138,2hbo)
        ierr=-1
        goto 900
C
C 1. Determine the type of parameter which was input with the command.
C    null = start with SOURCE before now+5min.
C    time = start with SOURCE before time.
C    #nnn = start with line nnn in file.
C
105   irec = -1
      if (nchar.lt.ic1.or.ic2.le.ic1+1) then
        call fc_rte_time(it,idum)      ! Get current time ...
        call iadt(it,5,3)           ! ... and add 5 minutes to it
        goto 200
      endif
C                            #
      if (cjchar(ibuf,ic1).ne.'#') then
        call gttim(ibuf,ic1,ic2-2,0,it1,it2,it3,ierr)
        if (ierr.lt.0) then
          call logit6(0,0,0,0,ierr,2hsp)
          goto 900
        endif
        it(5) = mod(it1,1024)
        it(4) = it2/60
        it(3) = mod(it2,60)
        it(2) = it3/100
        it(1) = 0
        goto 200
      endif
C
C 1.2 The case of #nnn - just position to the line and we're done.
C
      iline = ias2b(ibuf,ic1+1,ic2-ic1-2)
      ierr = 0
      if (iline.lt.0) then
        call logit7(0,0,0,1,-106,2hbo,iline)
        ierr = -1
        goto 900
      endif
      if (iline.le.1) goto 800
      irec2 = iline
      idum = fmpsetline(idcbsk,ierr,irec2-1)
      irecln = irec2
cxx      idum = fmpsetpos(idcbsk,ierr,irec2,ioff)
C                     Space down to the requested line
      if (ierr.ge.0) goto 800
      call logit7(0,0,0,1,-134,2hbo,ierr)
      goto 900
C
C
C     2. Search for a time in schedule file.
C     Desired time is in IT (HP format).
C
200   continue
      ilen = fmpreadstr(idcbsk,ierr,ibc)
      irecln = irecln + 1
      call char2low(ibc)
      if (ilen.le.0) then
        ierr = -1
        call logit6(0,0,0,0,-124,2hbo)
        goto 900
      endif
      if (ichcm_ch(ib,1,'source=').eq.0) then
        idum = fmpposition(idcbsk,ierr,irec,ioff)
        irec2=irec-ilen-1
        irec2ln = irecln-1
        ktime=.false.
C                     Remember the location of the last SOURCE command
        goto 200
      endif
      if (ktime) goto 200
      if (cjchar(ib,1).ne.'!') goto 200
C                          ! -- a wait-for command
      iec = iflch(ib,ilen*2)
      call gttim(ib,2,iec,0,it1,it2,it3,ierr)
      ktime=.true.
      if (kpast(it1,it2,it3,it)) goto 200
C                   If this time is in the past, go back and read some more
      if (irec.le.0) then
        call logit6(0,0,0,0,-132,2hbo)
        ierr = -1
        goto 900
      endif
cxx      irec2=irec-1
      idum = fmpsetpos(idcbsk,ierr,irec2,ioff)
C                     Re-position to the source command
      idum = fmpposition(idcbsk,ierr,irec2,id)
      iline = irec2ln
      irecln = irec2ln
      ierr = 0
C
C
800   idum = fmpposition(idcbsk,ierr,irec,ioff)
      icurln=irecln-1
      if(nlines.gt.0) ilstln = iline+nlines-1

C ** CLOSE DCB IF AN ERROR OCCURRED -- NRV 840709
900   if (ierr.lt.0) call fmpclose(idcbsk,inerr)

      return
      end
