      SUBROUTINE UNPSK(IBUF,IBLEN,lsname,ICAL,lfreq,
     .IPAS,LDIR,IFT,LPRE,IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,
     .LPST,NSTN,lstn,lcable,MJD,UT,GST,IMON,IDA,LMON,
     .LDAY,KERR,KFLG)!UNPACK SCHEDULE ENTRY 
C
C    UNPSK unpacks the record found in IBUF and puts the data into
C              the output variables
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer*2 ibuf(128)
      integer iblen
C      - buffer holding the schedule entry
C     IBLEN - length of the record in IBUF

C  OUTPUT:
      integer*2 lsname(max_sorlen/2),LPRE(3),LMID(3),lstn(max_stn),
     .          lcable(max_stn),lfreq,
     .          LMON(2),LDAY(2),ldir(max_stn),lpst(3)
      integer ift(max_stn),idur(max_stn),
     .          ipas(max_stn),
     .          ical,iyr,idayr,ihr,imin,
     .          isc,nstn,mjd,imon,ida,kerr
      logical KFLG(4)
      double precision UT,GST
C     lsname - source name
C     LPRE - pre-obs proc
C     LMID - mid-obs proc
C     lstn - station IDs
C     lcable - cable wrap
C     LMON, LDAY - name of month, day
C     IYR, IDA, IHR, iMIN, ISC - start time of obs
C     IDUR - duration
C     LPST - post-obs proc
C     ICAL - set-up time
C     lfreq - frequency code
C     IPAS - pass number
C     LDIR - direction of tape motion
C     IDUR - duration
C     IFT - footage counter at start
C     NSTN - number of stations in lstn
C     MJD - modified Julian date
C     UT - UT of start
C     GST - GST of start
C        KERR   - Error returned non-zero if problems.
C
C   COMMON BLOCKS USED
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
C
C  LOCAL VARIABLES
      double precision ST0,FRAC
C                    - for GST and SIDTM calculations
      integer ich,ic1,ic2,idummy,idurs,i,icp
      integer iscnc,ichmv,julda,ias2b,jchar ! functions
      integer ichmv_ch
C  History
C     880411 NRV DE-COMPC'D
C     890505 NRV CHANGED IDUR TO AN ARRAY, READ IN DURATIONS IF PRESENT
C 930407 nrv implicit none
C 960228 nrv Upper-case the frequency code
C 970114 nrv Change 8 to max_sorlen
C
      integer*2 LPASS(56)
C
C     1. We decode all of the entries in the buffer.
C     **CAUTION** No error checking is done.  It is assumed
C                 that the schedule entries were written by
C                 SKED originally and so should not have to
C                 be checked.
C     The format of the entries is the following:
C
C source cal code preob start duration midob idle postob scsc... pdfoot... flg
C     Example:
C     3C84      120 SX BYPREOB 800923120000  780 MIDOB   0 POSTOB K-F-G-OW 1F000
C*********NOTE: idle is decoded but not returned ****************
C     where all items are not restricted to specific columns.
C
c added 900628
      integer Z20,Z59
      data Z20/Z'20'/, Z59/Z'59'/
      DATA LPASS  /2H12,2H34,2H56,2H78,2H9A,2HBC,2HDE,2HFG,2HHI,2HJK,
     .             2HLM,2HNO,2HPQ,2HRS,2hTU,2hVW,2hXY,2hZa,2hbc,2hde,
     .             2hfg,2hhi,2hjk,2hlm,2hno,2hpq,2hrs,2htu,2hvw,2hxy,
     .             2hz , 25*0 /

      KERR = 0
      ICH = 1
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      CALL IFILL(lsname,1,max_sorlen,Z20)
      IDUMMY = ICHMV(lsname,1,IBUF,IC1,MIN0(IC2-IC1+1,max_sorlen))
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      ICAL = IAS2B(IBUF,IC1,IC2-IC1+1)
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      IDUMMY = ICHMV(lfreq,1,IBUF,IC1,2)
      call hol2upper(lfreq,2)
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      CALL IFILL(LPRE,1,6,Z20)
      IDUMMY = ICHMV(LPRE,1,IBUF,IC1,IC2-IC1+1)
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      IYR = IAS2B(IBUF,IC1,2)
      IDAYR = IAS2B(IBUF,IC1+2,3)
      IHR = IAS2B(IBUF,IC1+5,2)
      iMIN = IAS2B(IBUF,IC1+7,2)
      ISC = IAS2B(IBUF,IC1+9,2)
      MJD = JULDA(1,IDAYR,IYR)
      UT = IHR*3600.D0+iMIN*60.D0+ISC
      CALL SIDTM(MJD,ST0,FRAC)
      GST = DMOD(ST0 + UT*FRAC, 2.0d0*PI)
      IMON = 0
      IDA = IDAYR
      CALL CLNDR(IYR,IMON,IDA,LMON,LDAY)
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      IDURS= IAS2B(IBUF,IC1,IC2-IC1+1)
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      CALL IFILL(LMID,1,6,Z20)
      IDUMMY = ICHMV(LMID,1,IBUF,IC1,IC2-IC1+1)
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
c     IDLE = IAS2B(IBUF,IC1,IC2-IC1+1)
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      CALL IFILL(LPST,1,6,Z20)
      IDUMMY = ICHMV(LPST,1,IBUF,IC1,IC2-IC1+1)
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      DO 110 I=1,MAX_STN
        IDUMMY = ICHMV(lstn(I),1,IBUF,IC1+(I-1)*2,1)
        IF (JCHAR(lstn(I),1).EQ.Z20) GOTO 111
        IDUMMY = ICHMV(lcable(I),1,IBUF,IC1+1+(I-1)*2,1)
        IDUMMY = ichmv_ch(lcable(I),2,' ')
110     CONTINUE
111   NSTN= I-1
      DO 120 I=1,NSTN
        CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
        ICP = JCHAR(IBUF,IC1)
        IPAS(I) = ISCNC(LPASS,1,56,ICP)
        call char2hol('  ',LDIR(I),1,2)
	  IDUMMY = ICHMV(LDIR(I),1,IBUF,IC1+1,1)
	  IFT(I) = IAS2B(IBUF,IC1+2,ic2-ic1-1)
120     CONTINUE
        CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
        DO I=1,4
          KFLG(I) = .FALSE.
          IF (JCHAR(IBUF,IC1+I-1).EQ.Z59) KFLG(I) = .TRUE.
        END DO
C
C   NOW READ DURATIONS, IF PRESENT
C   IF NO DURATIONS, SET ALL TO THE ONE READ ABOVE
      CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
      IF (IC1.NE.0) THEN !read durations
        DO I=1,NSTN
          IDUR(I) = IAS2B(IBUF,IC1,IC2-IC1+1)
          CALL GTFLD(IBUF,ICH,IBLEN,IC1,IC2)
        ENDDO
      ELSE !set to default
        DO I=1,NSTN
          IDUR(I)=IDURS
        ENDDO
      ENDIF !read/default durations
      RETURN
      END
