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

C Input
      integer isor,icod ! indices for source and freq code
      integer istart(5) ! start year, doy, hr, min, sec

C Output
      integer irec ! non-zero is record number

C Local
      integer nch,is,iob,idum,ich,ic,ic1,ic2,iyr,ida,ihr,imin,isc
      integer ir,numc3,numc2
      integer*2 ibuf(ibuf_len),lsn(max_sorlen/2),lfrq,lstart(6)
      integer ib2as,ichcm,ias2b,ichmv,igtso,igtfr

C 1. Find source name and frequency code.
C    Convert start time to Hollerith .

      numc2 = 2+o'40000'+o'400'*2
      numc3 = 3+o'40000'+o'400'*3
      idum = ichmv(lsn,1,lsorna(1,isor),1,max_sorlen)
      lfrq = lcode(icod)
      nch=1
      NCH = NCH + IB2AS(istart(1)-1900,lstart,nch,2)
      NCH = NCH + IB2AS(istart(2),lstart,NCH,numc3)
      NCH = NCH + IB2AS(istart(3),lstart,NCH,numc2)
      NCH = NCH + IB2AS(istart(4),lstart,NCH,numc2)
      NCH = NCH + IB2AS(istart(5),lstart,NCH,numc2)

C 1. Loop through all observations so far.  Check source, code, and time.
C     source   cal code preob start 
C     Example:
C     3C84      120 SX PREOB 80092120000  
C                            yydddhhmmss
      irec = 0
      iob = 1
      do while (iob.le.nobs)
C       write(6,'("checking ",i4)') iob        
C       idum = ichmv(ibuf,1,lskobs(1,iskrec(iob)),1,ibuf_len*2)
        ir=iskrec(iob)
        ICH = 1
C  Source name
        CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
        if (ichcm(lsn,1,lskobs(1,ir),ic1,max_sorlen).eq.0) then ! continue
C  Skip cal time
          CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
C  Freq code
          CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
          if (ichcm(lfrq,1,lskobs(1,ir),ic1,2).eq.0) then ! continue
C  Skip preob
            CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
C  Start time
            CALL GTFLD(lskobs(1,ir),ICH,IBUF_LEN*2,IC1,IC2)
            if (ichcm(lstart,1,lskobs(1,ir),ic1,11).eq.0) then ! got it
              irec = iob
C             write(6,'("matched ",i5)') irec
              return
            endif
          endif ! code
        endif ! source
        iob = iob + 1 ! try the next one
      enddo

      RETURN
      END

