      subroutine findscan(isor,icod,istart,irec)

C   FINDSCAN looks through the list of scans for a match
C   on the source, code, and start time. 

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'

C History
C 960527 nrv New.
C 970114 nrv Chane 8 to max_sorlen
C 970131 nrv Don't check using exact columns, but get fields.
C 000106 nrv Check the year before converting to 2-digit internal year.
C 001108 nrv Use nsorlen array instead of finding the last character
C            in the source name each time we are called.
C 001108 nrv Remove GTFLDs and use known values for field lengths.
C 001108 nrv Use the input irec value, if non-zero, as the record
C            to start checking. If nothing is found, check the
C            scans behind us.

C Input
      integer isor,icod ! indices for source and freq code
      integer istart(5) ! start year, doy, hr, min, sec

C Output
      integer irec ! non-zero is record number

C Local
      integer nch,is,iob,idum,ich,ic,ic1,ic2,iyr,ida,ihr,imin,isc
      integer iob_end,irec_save,icsor,ir,numc3,numc2,itry
      integer*2 ibuf(ibuf_len),lstart(6)
      integer iflch,ib2as,ichcm,ias2b,ichmv,igtso,igtfr

C 1. Find source name and frequency code.
C    Convert start time to Hollerith .

      numc2 = 2+o'40000'+o'400'*2
      numc3 = 3+o'40000'+o'400'*3
      nch=1
      if (istart(1).ge.2000) iyr = istart(1)-2000
      if (istart(1).lt.2000) iyr = istart(1)-1900
      NCH = NCH + IB2AS(iyr,lstart,nch,numc2)
      NCH = NCH + IB2AS(istart(2),lstart,NCH,numc3)
      NCH = NCH + IB2AS(istart(3),lstart,NCH,numc2)
      NCH = NCH + IB2AS(istart(4),lstart,NCH,numc2)
      NCH = NCH + IB2AS(istart(5),lstart,NCH,numc2)

C 1. Loop through all observations so far.  Check source, code, and time.
C     source   cal code preob start 
C     Example:
C     3C84      120 SX PREOB 80092120000  
C                            yydddhhmmss
C iob is the observation to start with in the existing scan array.
      iob = 1
      if (irec.gt.0) iob = irec+1 ! start looking where we left off
      iob_end = nobs ! go to the end of the scans so far
      irec_save = irec ! save the initial scan number
      irec = 0 ! initialize the returned value to zero
      do itry=1,2 
        if (itry.eq.2) then ! didn't find a match the first time
          iob = 1 ! start again at the top
          iob_end = irec_save
        endif
      do while (iob.le.iob_end)
C       write(6,'("checking ",i4)') iob        
C       idum = ichmv(ibuf,1,lskobs(1,iskrec(iob)),1,ibuf_len*2)
        ir=iskrec(iob)
        ICH = 1
C  Source name
C       icsor=iflch(lsorna(1,isor),max_sorlen) ! new source name
        CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2) ! scan source name
C       if (ichcm(lsorna(1,isor),1,lskobs(1,ir),ic1,ic2-ic1+1).eq.0
C    .     .and.ic2-ic1+1.eq.icsor) then ! continue
        if (ichcm(lsorna(1,isor),1,lskobs(1,ir),ic1,ic2-ic1+1).eq.0
     .     .and.ic2-ic1+1.eq.nsorlen(isor)) then ! continue
C  Skip cal time
C         CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
C  Freq code
C         CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
          ic1 = nsorlen(isor) + 6
          if (ichcm(lcode(icod),1,lskobs(1,ir),ic1,2).eq.0) then ! continue
C  Skip preob
C           CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
C  Start time
C           CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
            ic1 = nsorlen(isor) + 16
            if (ichcm(lstart,1,lskobs(1,ir),ic1,11).eq.0) then ! got it
              irec = iob
C             write(6,'("matched ",i5)') irec
              return
            endif
          endif ! code
        endif ! source
        iob = iob + 1 ! try the next one
      enddo
      enddo ! itry=1,2

      RETURN
      END

