      subroutine newscan(istn,isor,icod,istart,
     .      idur,ifeet,ipas,lcb,ierr)

C   NEWSCAN forms the inputs into a standard sked/drudg hollerith 
C   observation.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

C Called by: VOBINP, VOB1INP
C History
C 960527 nrv New.

C Input:
      integer istn ! first station in this scan
      integer isor ! source index
      integer icod ! freq code index
      integer istart(5) ! year, doy, hour, min, sec
      integer idur ! duration of scan
      integer ifeet ! footage counter at start
      integer ipas ! pass number, F/R from even/oddness
      integer*2 lcb ! cable wrap

C Output:
      integer ierr ! if anything went wrong

C Local
      integer*2 ibuf(ibuf_len)
      integer iblen,i,ical,nch,idl
      integer ichcm_ch,ichmv,ichmv_ch,ib2as
      integer numc2,numc3,numc4,numc5
      logical kfor
      character*1 pnum ! function

C Initialized for leading zeros, left justified
      numc2 = 2+o'40000'+o'400'*2
      numc3 = 3+o'40000'+o'400'*3
      numc4 = 4+o'40000'+o'400'*4
      numc5 = 5+o'40000'+o'400'*5

C     First clear out the entire buffer
      CALL IFILL(IBUF,1,IBUF_LEN*2,oblank)
C     Source name is first
      NCH = ICHMV(IBUF,1,LSORNA(1,ISOR),1,8)
C     Cal time. Define as 10 for now
      ical = 10
      nch = nch + 1 + IB2AS(ICAL,IBUF,NCH+1,3)
C     Freq code
      NCH = ICHMV(IBUF,NCH+1,LCODE(ICOD),1,2)
C     Preob 
      NCH = 1 + ICHMV_ch(IBUF,NCH+1,'PREOB ')
C     Start time
      NCH = NCH + IB2AS(istart(1)-1900,IBUF,NCH,2)
      NCH = NCH + IB2AS(istart(2),IBUF,NCH,numc3)
      NCH = NCH + IB2AS(istart(3),IBUF,NCH,numc2)
      NCH = NCH + IB2AS(istart(4),IBUF,NCH,numc2)
      NCH = NCH + IB2AS(istart(5),IBUF,NCH,numc2)
C     Duration. Use first station's.
      NCH = NCH + 1+IB2AS(idur,IBUF,NCH+1,5)
C     Midob procedure
      NCH = ICHMV_ch(IBUF,NCH+1,'MIDOB ')
C     Idle time
      idl = 0
      NCH = NCH + 1+IB2AS(IDL,IBUF,NCH+1,5)
      NCH = NCH + 1
C     Postob proc
      NCH = ICHMV_ch(IBUF,NCH,'POSTOB')
      NCH = NCH + 1
C     Station code
      NCH = ICHMV(IBUF,NCH,LSTCOD(ISTN),1,1)
      NCH = ICHMV(IBUF,NCH,LCB,1,1)
C   Insert blanks for other stations' codes
      nch = nch + nstatn*2
C   Tape pass, direction, footage for each station
      if (ichcm_ch(lstrec(1,istn),1,'S2').eq.0) then
        kfor=.true. ! always forward
        nch=ichmv_ch(ibuf,nch,cpassorderl(ipas,istn)(1:1)) ! group number
      else
        NCH = ICHMV_ch(IBUF,NCH+1,pnum(ipas))
        i=ipas/2
        kfor= ipas.ne.i*2 ! odd forward, even reverse
      endif
      if (kfor) then
        NCH = ICHMV_ch(IBUF,NCH,'F')
      else
        NCH = ICHMV_ch(IBUF,NCH,'R')
      endif
C  Put in footage. For S2 this is in seconds.
      NCH=  NCH+IB2AS(ifeet,IBUF,NCH,numc5)
C   Insert blanks for other stations' footages
      nch = nch + nstatn*8
C  Procedure flags
      nch = ichmv_ch(ibuf,nch,'YNNN')
C  Duration
      NCH = 1 + NCH + IB2AS(IDUR,IBUF,NCH+1,5)
C   Insert blanks for other stations' durations
      nch = nch + nstatn*6
C  Length of buffer
      iblen = nch/2
C
C Store the record in common

      ierr=0
      if (nobs+1.gt.max_obs) then ! too many
        ierr=max_obs
        return
      endif
      NOBS = NOBS + 1
C     write(6,'(i5)') nobs
      ISKREC(NOBS) = nobs
      DO I=1,ibuf_len
        LSKOBS(I,ISKREC(NOBS)) = IBUF(I)
      END DO

      return
      end
