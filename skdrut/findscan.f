      subroutine findscan(isor,icod,istart,irec)

C   FINDSCAN looks through the list of scans for a match
C   on the source, code, and start time. 

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'

C History
C 960527 nrv New.

C Input
      integer isor,icod ! indices for source and freq code
      integer istart(5) ! start year, doy, hr, min, sec

C Output
      integer irec ! non-zero is record number

C Local
      integer is,iob,idum,ich,ic,ic1,ic2,iyr,ida,ihr,imin,isc
      integer*2 ibuf(ibuf_len),lsn(4),lfrq
      integer ias2b,ichmv,igtso,igtfr


C 1. Loop through all observations so far. 
C     source   cal code preob start 
C     Example:
C     3C84      120 SX PREOB 800923120000  

      irec = 0
      iob = 1
      do while (iob.le.nobs)
        
        idum = ichmv(ibuf,1,lskobs(1,iskrec(iob)),1,ibuf_len*2)
        ICH = 1
C  Source name
        CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
        CALL IFILL(LSN,1,8,oblank)
        IDUM = ICHMV(LSN,1,IBUF,IC1,MIN0(IC2-IC1+1,8))
        IF  (IGTSO(LSN,IS).eq.isor) then ! continue
C  Skip cal time
          CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
C  Freq code
          CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
          IDUM = ICHMV(LFRQ,1,IBUF,IC1,2)
          IF  (IGTFR(LFRQ,IC).EQ.icod) then ! continue
C  Skip preob
            CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
C  Start time
            CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
            IYR = 1900+IAS2B(IBUF,IC1,2)
            IDA = IAS2B(IBUF,IC1+2,3)
            IHR = IAS2B(IBUF,IC1+5,2)
            IMIN = IAS2B(IBUF,IC1+7,2)
            ISC = IAS2B(IBUF,IC1+9,2)
            if (iyr.eq.istart(1).and.ida.eq.istart(2).and.
     .      ihr.eq.istart(3).and.imin.eq.istart(4).and.
     .      isc.eq.istart(5)) then ! got it
              irec = iob
              return
            endif
          endif ! code
        endif ! source
        iob = iob + 1 ! try the next one
      enddo

      RETURN
      END

