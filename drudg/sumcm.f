      SUBROUTINE SUMCM(LINSTQ)
C
C  SUMCM produces a summary of the schedule
C
      include '../skdrincl/skparm.ftni'
      include 'skcom.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT VARIABLES:
      integer*2 LINSTQ(*) ! - input string with DTR, word 1=length
C
C  OUTPUT VARIABLES:
C
C Called by: FSKED
C Calls: GTRUN, GTOBS, GTPRE, 
C
C LOCAL VARIABLES
      integer*4 npairs
      integer look ! set to 0 for slewt call
      real POBS(MAX_STN),PCAL(MAX_STN),PSLW(MAX_STN)
C               - percentages for time slewing, observing, cal.
      real apobs,apcal,apslw,apidle
      integer ianh,iastcnt,ibst,iadobs,iadgB
      double precision adgb
      real SITOBS(MAX_STN),SITCAL(MAX_STN),TSLW(MAX_STN),dobs(max_stn),
     .     dgB(max_stn),trate,sitobb(max_stn),tottapes,fdgb(max_stn)
C               - total time observing, cal., slewing
      integer*2 LINES(MAX_BASELINE)
C               - output line for baseline summary
      integer NSPRE(MAX_STN)
      integer*2 LCBPRE(MAX_STN)
      real PIDLE(MAX_STN)
      integer ISTCNT(MAX_STN),NTAPES(MAX_STN)
      real fntapes(max_stn)
      logical kmore
      double precision tape_change_time(max_change_list,max_stn)
      integer tphr(10,max_stn),tpmn(10,max_stn)
C               - # obs and tapes by station
      integer IDTCUR(MAX_STN)
C               - times by station
      character*96 cline
C               - output time line for source observations
      integer IDIRPR(MAX_STN),IPASPR(MAX_STN),IFTPRE(MAX_STN)
C               - holds pre direction, pass & feet by stn for tape counting
      integer IDURPR(MAX_STN),ICODPR(MAX_STN),itupr(max_stn),
     .iftend(max_stn)
      integer IUTRIS(MAX_STN),IUTSET(MAX_STN)
      double precision UT1,UT2,UTOFF,UTEF
C               - starting, stopping UTs
      real elhist(18,max_stn+1) ! el histogram
      integer nbins     ! dimension of this array
      real elhistx(10,max_stn+1) ! el histogram
      integer nbinsx
      real elhistlo(11) ! histogram for low elevations
      integer ibinlo,ik
      integer iklo ! number of stations with low-el observations
      real covhist(20,max_stn+1) ! coverage histogram
      integer ncobins     ! dimension of this array
      real skycov(max_obs,2,max_stn) ! all az-el for schedule
      real az1,az2,el1,el2,sin1,sin2,cos1,cos2,aa,dista,cosd
      integer idista(18),i1,i2
      real rdista(18)
      integer isnhist(18,max_band,max_baseline+1) ! SNR histogram
      integer nsnr(max_band)
      double precision sumsnr(max_band),avgsnr
      integer iband(max_band),nba,iba !band indices
      LOGICAL KSTART,KRWND,KGOT,KNEWT
C               - for GTOBS
      LOGICAL KBIT,KEX
      integer ICOUNT(MAX_SOR),iocount(max_sor)
      integer ibcount(max_sor,max_baseline),ibsum(max_baseline)
C      - number of obs by source
      integer ibnumob(max_stn) ! number of n-station obs
      integer ILINE(6,MAX_SOR) ! one bit per source per time unit
      character*2 ctype
      LOGICAL KSK
C      - true if one of the required subnet stations is in this obs
      LOGICAL KBASE
C      - true if 1st baseline station is in this obs.
      integer IBSELN(MAX_BASELINE)
C      - #obs per baseline counters
C     xmin,xmax,ymin,ymax - optional plotting limits
C     NST - number of stations requested
      integer IST(MAX_STN)
C      - list of stations requested
      logical kskp
C      - true if this station's observation is to be plotted
      logical kup
C      - true if source is up, from CVPOS
      integer nch,trimlen  !variable and function for variable length
      integer i,j,k,ierr,j1,mjd1,mjd2,ij,is,js,ib,iut,ibl
      integer ibin,ic,ii,jj,kk,nst,istim,iftold,ictot,blnk
      integer nazseg,nelseg,iazbin,ielbin,iijj,iij,imaxrun
      integer ilin,ip,inum,itot,idummy,kj,iotot,imoff,ks,icn,ittime,
     .issum,isssum,mutris,mutset
      real tslew,trise,eld,azd,uth,tot,tot3,tot5,tot7
      real totst,tots2,astrms,atotst
      integer iptot3,iptot5,iptot7,iptot
      real xmax,ymax,xmin,ymin,az,el,ha,dec,x30,y30,x85,y85,xd,yd
      integer ichmv_ch,ichmv,ib2as,ibnum ! functions
      real speed ! function
      integer sonum ! function
      integer luplt(max_stn) !one data file for each station
      character*128 cplnam
      character*2 cnum
      logical kvis ! false (true for muvis calls)
      integer nvarn,navg,nsdmax,njdmax,nkdmax,ndnob
      real coavg,corms,cotot,coto2,acotot,acoto2,acoavg,acorms
      integer totne,totse,totsw,totnw,totup
      double precision busum,bxsum,bysum,blsum
      double precision varn,dnob,vavg,davgr,davgs,dvar,dmaxnob,dminnob,
     .dnobs(max_sor),snrtot,snrtot2
      real uniform5(18),uniform10(18)
      integer islew_info     !info about slewing
      integer num_mk5_tracks    !number mark5 tracks recorded
      integer ipow2
C     integer iuniform5(18),iuniform10(18)

C  INITIALIZED
      DATA ILIN/MAX_BASELINE/,istim/0/
C     data iuniform5/2,5,7,9,10,10,11,10,9,8,7,5,4,3,1,1,0/
C     data iuniform10/2,5,7,9,11,11,11,10,9,8,6,5,3,2,1,0,0,0/
      data uniform5 /1.6,4.5,6.8,8.6,9.8,10.4,10.5,10.1,9.2,8.1,6.7,
     .5.3,3.8,2.5,1.4,0.6,0.1,0.0/
      data uniform10/1.7,4.9,7.4,9.3,10.5,11.0,10.9,10.3,9.2,7.9,6.3,
     .4.7,3.2,1.8,0.8,0.1,0.0,0.0/
C
C  HISTORY
C    811125  MAH    BASELINE SUMMARY ADDED AT THE END.
C    831117  WEH    FIXED SOURCE PLOT FOR UTCUR(J) NOT UTCUR
C    840813  MWH    Added printer LU lock, header for listing,and
C                   # of obs for indiv stations to matrix display
C    841111  MWH    Added expanded summary display
C    880314  NRV    DE-COMPC'D
C ** 880320  NRV    HARD-CODED FORMAT STATEMENTS WHICH FORMERLY
C                   HAD PARAMETERS E.G. MAX_STNA1.
C    880121  NRV    Moved EX parameter to IGTKY
C    890518  NRV    Added total number of obs at end
C    890531  NRV    Cleaned up format of code.
C                   Added section to calculate az,el for plots
C    890612  NRV    Removed command line parsing to SUMPR
C                   Added windows common statement and code to
C                   fill in values.
C    890711  NRV    Added total # obs by source to LINE display
C    890720  NRV    Check plot limits before sending to X
C    900327  NRV    Added lookah to SLEWT call
C    900425  NRV    Added BASELINE summary option
C    910619  NRV    Added trise to SLEWT call
C                   Changed to stats-only as default display
C                   Added # n-station obs display
C    910620  NRV    Added el histogram display
C    910712  NRV    Added SNR histogram
C    910924  NRV    Add mjd,ut to SNR call
C    930225  nrv    implicit none
C    930325  nrv    Fixed accumulation of observing time statistics to
C                   add in the correct station's time. Previously had
C                   always added the duration for station 1.
C    930429  nrv    Initialize UTOFF to 0. This is a non-implemented option
C                   to offset the LINE summary display.
C    930430  nrv    Write out data file for plotting, call pc8 to plot
C    930616  nrv    Modify sumpl call to add kvis argument
C    931005  nrv    Add coverage option
C    931020  nrv    Add a line to the elevation histogram with numbers
C                   of observations in each bin
C    931021  nrv    Add itsris to SLEWT call
C    931108  nrv    Corrected low-elevation observation histogram. Bin values
C                   by truncating, e.g. obs between 3.1 and 3.9 all below in
C                   the bin of el=3 to 4. Previously had been rounding.
C    931109  nrv    change itsris to tsris for double precision
C    931112  nrv    Add st0,frac to slewt call
C    940208  nrv    Set lookahead to 0 for slewt call
C    940209  nrv    Normalize sky coverage display by total number of pairs.
C    940216  nrv    Add random sky distribution values as a gauge.
C    940218  nrv    Add sky distribution histogram plots.
C    940513  nrv    Set cable to "V" for special VLBA slewing algorithm.
C    950404  nrv    Change to using position ID instead of 1-letter code.
C 951018 nrv Remove holleriths
C 951116 nrv Add station index to SPEED call
C 960715 nrv Add list of average baseline components at end
C 960723 nrv Change formatting to write out average number of scans/hour
C            with one decimal point. Fix calculation of fractional number
c            of tapes per station.
C 960923 nrv ITEARL array
C 970328 nrv Add running time for SNR calculations
C 990617 nrv Don't use incremented baseline number but calculate it.
C 000124 nrv Enlarge format 9390 to print a full line!
C 020103 nrv List tape change times
C 020620 nrv Accumulate tape change times for first max_change_list.
C 020815 nrv Calculate GBytes recorded. Re-arrange lines of summary.
C 020917 nrv Calculate number of 8-pk needed. 
C
C
C   1. Parse command line
C
      call sumpr(linstq,nst,ist,ctype,xmin,xmax,ymin,ymax,ierr)
      kex=.false.
      if (iwscn.gt.79) kex=.true.
      if (ierr.ne.0) return
      utoff = 0.d0
C
C
C   2. Initialize arrays, print header line, open plot file.
C
      nch = trimlen(cskfil)
      if (ctype.ne.'EL'.and.ctype.ne.'PO'.and.ctype.ne.'XY'
     .    .and.ctype.ne.'AZ') then
        WRITE(LUDSP,9100) CSKFIL(1:nch),LEXPER
9100    FORMAT(/3X'SKED Summary from file 'A' for experiment '4A2/)
        IF  (.NOT.KBSELN) THEN  !baseline off
          WRITE(LUDSP,9101)
9101      FORMAT(6X,'(all scans with at least one subnet ',
     .    'station)'/)
        ELSE  !baseline on
          IF  (.NOT.KPART) THEN  !part off
            WRITE(LUDSP,9102)
9102        FORMAT(6X,'(all scans containing entire subnet)'/)
          ELSE  !part on
            WRITE(LUDSP,9103)
9103        FORMAT(6X,'(all scans with at least two subnet ',
     .      'stations)'/)
          END IF  !part on
        END IF  !baseline on
      end if
      if (ctype.eq.'HI') then
        write(ludsp,'("Elevation histogram")')
      else if (ctype.eq.'CO') then
        write(ludsp,'("Sky coverage histogram")')
      else if (ctype.eq.'SN') then
        write(ludsp,'("SNR histogram")')
      endif
C
      if (ctype.eq.'LI') then
        CALL SUMHD(KEX,ISTIM,LUDSP,IBUF,IBLEN)
      else if (ctype.eq.'FI') then !plot file
        open(90,status='unknown',file=cplfil,iostat=ierr)
        if (ierr.ne.0) then
          write(luscn,9091) ierr,cplfil
9091      format('SUMCM - Error 'i5' opening 'a16' for plot data.')
          return
        endif
      else if (ctype.eq.'BA') then !baseline header
C       write(ludsp,9092) cskfil(1:nch),lexper
9092    format(/3x,'SKED Baseline Summary from file ',
     .  A,' for experiment '4a2//10x,$)
        write(ludsp,'(10x,$)')
          do i=1,nst-1
            do j=i+1,nst
C             write(ludsp,9203) lstcod(ist(i)),lstcod(ist(j))
              write(ludsp,9203) lpocod(ist(i)),lpocod(ist(j))
9203          format(1x,a2,'-',a2,$)
            enddo
          enddo
          write(ludsp,'(" Tot")')
      else if (ctype.eq.'XY'.or.ctype.eq.'EL'.or.ctype.eq.'PO'
     ..or.ctype.eq.'AZ'.or.ctype.eq.'DI') then ! set up files for plots
        do i=1,nst 
          j=ist(i)
          luplt(j) = 100+j
c         write(cnum,'(a1)') lstcod(j)
          write(cnum,'(a2)') lpocod(j)
          nch = trimlen(ctmfil)
          cplnam = ctmfil(1:nch)//'.'//cnum
          open(luplt(j),file=cplnam,status='unknown',iostat=ierr)
          if (ctype.eq.'XY'.or.ctype.eq.'PO')
     .    call horpl(j,xmin,xmax,ymin,ymax,ctype,luplt(j))
        enddo
      endif
C
      KSTART=.TRUE.
      KRWND=.FALSE.
      KBASE=.FALSE.
C
      DO  I=1,NSOURC
        ICOUNT(I)=0
        iocount(i)=0
        do k=1,max_baseline
          ibcount(i,k)=0
        enddo
        DO  J=1,6
          ILINE(J,I)=0
        END DO
      END DO 
      DO  I=1,MAX_BASELINE
        IBSELN(I)=0
        ibsum(i)=0
      END DO
      do i=1,11
        elhistlo(i)=0.0
      enddo
      nbins = 18
      nbinsx = 10
      ncobins=20
      nazseg = 4
      nelseg = 5
      nvarn=0
      vavg=0.d0
      navg=0
      varn=0.d0
      DO  I = 1,MAX_STN
        SITOBS(I)=0
        SITOBB(I)=0
        SITCAL(I)=0
        TSLW(I)=0
        NTAPES(I)=0
        do j=1,max_change_list
          tape_change_time(j,i)=0.d0
        enddo
        ISTCNT(I)=0
        IDIRPR(I)=-1
        IPASPR(I)=0
        IFTPRE(I)=0
        NSPRE(I)=0
        call char2hol ('  ',LCBPRE(I),1,2)
        IDURPR(I)=0
        ICODPR(I)=1
        ibnumob(i)=0
        do j=1,nbinsx
          elhistx(j,i)=0
        enddo
        do j=1,nbins
          elhist(j,i)=0
        enddo
        do j=1,ncobins
          covhist(j,i)=0
        enddo
      END DO 
      do j=1,nbinsx
        elhistx(j,max_stn+1)=0
      enddo
      do j=1,nbins
        elhist(j,max_stn+1)=0
      enddo
      do j=1,ncobins
        covhist(j,max_stn+1)=0
      enddo
      busum=0.d0
      bxsum=0.d0
      bysum=0.d0
      blsum=0.d0
      do j=1,max_band
        sumsnr(j)=0.d0
        nsnr(j)=0
      enddo
      do j=1,nbins
        do i=1,max_baseline+1
          do k=1,max_band
            isnhist(j,k,i)=0
          enddo
        enddo
      enddo
      MJD1=-1
C     tproc= ITAPTM+ISORTM+ITAPTM+IMODTM
C
C
C    4.  Get each scans and accumulate it if the source/station
C     list is satisfied.
C
      CALL GTOBS(KSTART,KRWND,KGOT,IERRCM)
      DO WHILE (KGOT) !main loop getting observations
        IF  (IERRCM.NE.0) THEN
          CALL WRERR(IERRCM,INUMCM)
          RETURN
        END IF  
        J1 = ISTCUR(1)
        K = NSORcur(J1)
        KSK=.FALSE.
        IF  (KBSELN) THEN
          IC=0
          DO  I=1,NST
            JJ=IST(I)
            DO  KK=1,nstncur
              IF (JJ.EQ.ISTCUR(KK)) IC=IC+1
            END DO
          END DO 
          IF (IC.EQ.NST.OR.(KPART.AND.IC.GE.2)) KSK = .TRUE.
        ELSE 
          DO  I=1,NST !check stations
            DO  II=1,nstncur
              IF (IST(I).EQ.ISTCUR(II)) KSK=.TRUE.
            END DO
          END DO  !check stations
        END IF 
        IF (ISORCM.NE.0.AND.K.NE.ISORCM) KSK=.FALSE.
C
C   5. This scan is to be included.     
C      Count observations on each of the baselines.
C      Mark the scans in the source line display,
C   or write out the data to be plotted.
C   or fill in windows common block.
C
        IF  (KSK) THEN !include this one
          iklo=0 !initialize count for any stations with low elevations this obs
          ibinlo=0
          IC=0
          DO  I=1,NST-1 !count baselines
            DO  II=1,nstncur
              IF (IST(I).EQ.ISTCUR(II)) KBASE=.TRUE.
            END DO
            IF  (KBASE) THEN
              DO  IJ=I+1,NST
C               Don't just increment the count but get the baseline number
C               IC=IC+1
                ic=ibnum(ist(i),ist(ij))
                DO  II=1,nstncur
                  IF(IST(IJ).EQ.ISTCUR(II)) then !increment
                    IBSELN(IC)=IBSELN(IC)+1
C                   iocount(k)=iocount(k)+1
                  endif !increment
                END DO
              END DO 
              KBASE=.FALSE.
            ELSE
              IC=IC+NST-I
            ENDIF
          END DO  !count baselines
          UTEF = UTCUR(J1)-UTOFF
          IF (UTEF.LT.0.D0) UTEF = UTEF+86400.D0
          IF  (IWSCN.GT.79) THEN
            IUT = 1+UTEF/900.D0
          ELSE
            IUT = 1+UTEF/1800.D0
C                   Index in units of 15 or 30 minutes
          ENDIF
          ICOUNT(K)=ICOUNT(K)+1
          DO  I = 1,nstncur
            ISTCNT(ISTCUR(I)) = ISTCNT(ISTCUR(I))+1
          END DO
C       Increment count of observations by baseline
          do i=1,nstncur-1
            do j=i+1,nstncur
              is=istcur(i)
              js=istcur(j)
              ib = ibnum(is,js)
              busum = busum + dsqrt(bx(ib)*bx(ib)+by(ib)*by(ib))
              bxsum = bxsum + dsqrt(bx(ib)*bx(ib)+bz(ib)*bz(ib))
              bysum = bysum + dsqrt(by(ib)*by(ib)+bz(ib)*bz(ib))
              blsum = blsum + baselen(ib)
              ibcount(k,ib) = ibcount(k,ib)+1
            enddo
          enddo
          iocount(k)=iocount(k)+(nstncur*(nstncur-1))/2
          ibnumob(nstncur)=ibnumob(nstncur)+1

C       Main if-test for summary options starts here:
        if (ctype.eq.'LI') THEN !mark this scan on the appropriate source line
          CALL SBIT(ILINE(1,K),IUT,1)
        else if (ctype.eq.'BA') then
        else if (ctype.eq.'SN') then
          if (.not.krsini) call rsini
          do i=1,nstncur
            j=istcur(i)
            idurst(j)=idurcur(j)
          enddo
          j=istcur(1)
          call snrac(nstncur,istcur,nsorcur(j),icodcur(j),-1,mjdcur(j),
     .    utcur(j),ierr)
          call gtban(icodcur(j),nba,iband)
          do ib=1,nba !bands
            iba=iband(ib)
            do i=1,nstncur-1
              do j=i+1,nstncur
                is=istcur(i)
                js=istcur(j)
                ibl = ibnum(is,js)
                sumsnr(iba)=sumsnr(iba)+iactbl(iba,ibl)
                nsnr(iba)=nsnr(iba)+1
                ibin = min(nbins,iactbl(iba,ibl)/5 + 1)
                if (ibin.lt.0) ibin=1
                isnhist(ibin,iba,ibl) = isnhist(ibin,iba,ibl)+1
              enddo
            enddo
          enddo !bands
        else if (ctype.eq.'AZ'.or.ctype.eq.'EL'.or.ctype.eq.'XY'.
     .  or.ctype.eq.'PO'.or.ctype.eq.'FI'.or.ctype.eq.'HI'.
     .  or.ctype.eq.'CO'.or.ctype.eq.'DI') then 
C             write out a line for each station's scans to be plotted
          do i=1,nstncur
            j=istcur(i)
            kskp=.false.
            ij=1
            do while (ij.le.nst.and..not.kskp)
              if (j.eq.ist(ij)) kskp=.true.
              ij=ij+1
            enddo
            if (kskp) then !this station
              call cvpos(k,j,mjdcur(j),utcur(j),az,el,ha,
     .        dec,x30,y30,x85,y85,kup)
              if (ctype.eq.'FI') THEN !plot file
                write(90,9111) lstcod(j),k,az*180.0/pi,
     .          el*180.0/pi,utcur(j)/3600.d0
9111            format(a1,i4,2f7.1,f7.2)
              else if (ctype.eq.'HI'.or.ctype.eq.'CO'
     .        .or.ctype.eq.'DI') then !histogram accum.
                eld = el*180.0/pi
                if (ctype.eq.'HI') then !el hist
                  ibin = eld/5.0 + 1
                  if (ibin.le.0) ibin=1
                  if (ibin.gt.nbins) ibin=nbins
                  elhist(ibin,j) = elhist(ibin,j) + 1
                  if (eld.lt.10.0) then !a low elevation observation
                    ibin = eld + 1
                    if (ibin.le.0) ibin=1
                    if (ibin.gt.nbinsx) ibin=nbinsx
                    elhistx(ibin,j) = elhistx(ibin,j) + 1
                    iklo=iklo+1
                    if (iklo.eq.1) then !first station
                      ibinlo=eld+1
                      if (ibinlo.le.0) ibinlo=1
                      if (ibinlo.gt.11) ibinlo=11
                    else !another was low too
                      ibinlo=min(ibinlo,int(eld+1))
                      if (ibinlo.le.0) ibinlo=1
                      if (ibinlo.gt.11) ibinlo=11
                    endif
                  endif
                else !coverage hist
                  azd = az*180.0/pi
                  iazbin = azd/(360/nazseg) + 1
                  ielbin = sin(el)*nelseg + 1
                  ibin = (iazbin-1)*nelseg + ielbin
                  if (ibin.le.0) ibin=1
                  if (ibin.gt.ncobins) ibin=ncobins
                  covhist(ibin,j)=covhist(ibin,j)+1
                  skycov(istcnt(j),1,j)=az
                  skycov(istcnt(j),2,j)=el
                endif
              else ! plots
                azd = az*180.0/pi
                eld = el*180.0/pi
                if (eld.ge.ymin.and.eld.le.ymax) then !within el limits
                  if (ctype.eq.'XY'.or.ctype.eq.'PO') then
                    if (azd.ge.xmin.and.azd.le.xmax) then !within az limits
                      if (ctype.eq.'XY') then
                        write(luplt(j),9607) sonum(k),azd,eld
9607                    format(i3,2f8.3)
                      else !PO
                        call azel2xy(azd,eld,xd,yd)
                        write(luplt(j),9607) sonum(k),xd,yd
                      endif
                    endif !within az limits
                  else ! EL or AZ vs time
                    uth = utcur(j)/3600.d0
                    if (uth.ge.xmin.and.uth.le.xmax) then !within ut limits
                      if (ctype.eq.'EL') then 
                        write(luplt(j),9607) sonum(k),uth,eld
                      else 
                        write(luplt(j),9607) sonum(k),uth,azd
                      endif
                    endif !within ut limits
                  endif ! EL or AZ vs time
                endif !within el limits
              endif ! plots
            endif !this station
          enddo ! 1,nstncur
          if (ctype.eq.'HI'.and.iklo.gt.0) then !low-elevation obs
            do ik=1,iklo
              elhistlo(ibinlo)=elhistlo(ibinlo)+nstncur-iklo
            enddo
          endif
        endif
C
C
C    6. Accumulate statistics
C
        if (ctype.eq.'LI'.or.ctype.eq.'ST'.or.ctype.eq.'BA') THEN !stats
          if (.not.krsini) call rsini
          IF (MJD1.LE.0) THEN !first scans
            UT1=UTCUR(J1) - ICALcur(J1)
            MJD1=MJDCUR(J1)
          ENDIF !first scans
          UT2=UTCUR(J1) + IDURcur(J1)
          MJD2=MJDCUR(J1)
          DO  IJ = 1,nstncur !add times for this scan
            KJ = ISTCUR(IJ)
            IDTCUR(KJ) = (MJDCUR(KJ)-MJD1)*1440+(UTCUR(KJ)-ICALcur(KJ))/
     .         60.D0
            SITOBS(KJ)=SITOBS(KJ)+IDURcur(kj)
            sitobb(kj)=sitobb(kj)+idurcur(kj)+itearl(kj)*itucur(kj)
            if (idurxt(kj).gt.0) then ! more time
              imaxrun=-1
              do iij=1,nstncur
                iijj=istcur(iij)
                if (iijj.ne.kj.and.idurxt(iijj).gt.imaxrun) 
     .            imaxrun=idurxt(iijj)
              enddo
              if (imaxrun.gt.0) then
                sitobs(kj)=sitobs(kj)+min(idurxt(kj),imaxrun)
                sitobb(kj)=sitobb(kj)+min(idurxt(kj),imaxrun)
              endif
            endif ! more time
            SITCAL(KJ)=SITCAL(KJ)+ICALcur(kj)
            IF (NSPRE(KJ).EQ.0) NSPRE(KJ) = NSORcur(KJ)
            call char2hol ('  ',BLNK,1,2)
            look=0
            CALL SLEWT(NSPRE(KJ),MJDCUR(KJ),UTCUR(KJ),NSORcur(KJ),KJ,
     >         LCBPRE(KJ),BLNK,TSLEW,look,trise,tsris,st0cur,frac,
     >         knov,islew_info)
            if (tslew.gt.0.0) TSLW(KJ) = TSLW(KJ)+TSLEW
            IFTOLD = IFTPRE(KJ)+IFIX(FLOAT(IDIRPR(KJ)*
     .      (itupr(kj)*ITEARL(kj)+IDURPR(KJ)))*SPEED(ICODPR(KJ),kj))
            IF (KNEWT(IFTCUR(KJ),IPAScur(KJ),IPASPR(KJ),IDIRcur(KJ),
     .       IDIRPR(KJ),IFTOLD)) then
                ntapes(kj) = NTAPES(KJ)+1
                if (ntapes(kj).le.max_change_list)
     .            tape_change_time(ntapes(kj),kj) = utcur(kj)
            endif
C           IDTPRE(KJ) = (MJDCUR(J1)-MJD1)*1440+(UTCUR(J1)+IDURcur(J1))/60.D0
            IDIRPR(KJ) = IDIRcur(KJ)
            IPASPR(KJ) = IPAScur(KJ)
            IFTPRE(KJ) = IFTCUR(KJ)
            NSPRE(KJ) = NSORcur(KJ)
            LCBPRE(KJ) = LCBLcur(KJ)
            IDURPR(KJ) = IDURcur(KJ)
          END DO  !add times for this scan
        endif !stats
C
        END IF  !include this one
C       Save the ending time of this scan 
        call GTPRE(idirpr,nspre,lcbpre,iftend,icodpr,itupr)
        CALL GTOBS(KSTART,KRWND,KGOT,IERRCM)
        if (kgot) call GTRUN(idirpr,nspre,lcbpre,iftend,icodpr,itupr) ! calculate run time and itucur, update utstart
      END DO ! main loop getting observations

      ICTOT = 0
      iotot = 0
      do i=1,nsourc !final accum. for stats
        ICTOT = ICTOT + ICOUNT(I)
        iotot = iotot + iocount(i)
      enddo !final accum. for stats

C     Calculate ratios of number of observations per hour "up"
        ITTIME = ((MJD2-MJD1)*86400.D0 + UT2 - UT1)/60.D0
C                   Compute total time in minutes
        davgr=0.d0
        davgs=0.d0
        nvarn = 0
        dmaxnob = 0.d0
        dminnob = 9999.d0
        DO  I=1,NSOURC !source loop
          dnobs(i)=0.d0
          ndnob=0
          IF (ISORCM.EQ.0.OR.(ISORCM.GT.0.AND.I.EQ.ISORCM)) THEN !include this source
            do j=1,nst-1
              js=ist(j)
              do k=j+1,nst
                ks=ist(k)
                ib=ibnum(js,ks)
                dnob=0.d0
                if (itimeup(i,ib).gt.0) then
                  dnob=1440.d0*dble(ibcount(i,ib))/dble(itimeup(i,ib))
                  if (dnob.gt.dmaxnob) then
                    dmaxnob = dnob
                    nsdmax = i
                    njdmax = js
                    nkdmax = ks
                  endif
                  if (dnob.lt.dminnob) dminnob = dnob
                  davgr = davgr + dnob
                  davgs = davgs + dnob*dnob
                  nvarn = nvarn+1
                  dnobs(i)=dnobs(i)+dnob
                  ndnob=ndnob+1
                endif
              enddo !k=j+1,nst
            enddo !j=1,nst-1
          endif !include this source
          if (ndnob.gt.0) dnobs(i)=dnobs(i)/dble(ndnob)
        enddo !source loop 
C
C
C     5. Now write out each line by source.
C     If one source was mentioned, list that one only.
C
      if (ctype.eq.'LI') then !display
        DO  I=1,NSOURC !display
          IF  (ISORCM.EQ.0.OR.(ISORCM.GT.0.AND.I.EQ.ISORCM)) THEN !show this one
            cline=" "
            DO  J=1,96
              IF (KBIT(ILINE(1,I),J)) cline(j:j)="x"
            END DO
            IF  (IWSCN.GT.79) THEN !mutual rise/set
              CALL VISSS(I,NST,IST,IUTRIS,IUTSET,MUTRIS,MUTSET)
              IMOFF = ISTIM*60
              MUTRIS = MUTRIS-IMOFF
              MUTSET = MUTSET-IMOFF
              IF (MUTRIS.LT.0) MUTRIS = MUTRIS+1440
              IF (MUTSET.LT.0) MUTSET = MUTSET+1440
              if(MUTRIS .ne. MUTSET) then
                IUT = 1+MUTRIS/15
                cline(iut:iut)="R"
                IUT = 1+MUTSET/15
                cline(iut:iut)="S"
              endif
!              WRITE(LUDSP,9281) cSORNA(I),LINE,ICOUNT(I),
!     >          iocount(i),dnobs(i)
            ELSE !plain
!              WRITE(LUDSP,9280) cSORNA(I),
!     .        (LINE(II),II=1,24),ICOUNT(I),iocount(i),dnobs(i)
            END IF  !plain
            WRITE(LUDSP,9281) cSORNA(I),cLINE,ICOUNT(I),
     >          iocount(i),dnobs(i)
9281        FORMAT(1X,A8,'|',A,'|',1x,I5,1x,i5,1x,f5.1)
          END IF  !show this one
        END DO  !display
        if (iwscn.gt.79) then 
          write(ludsp,9282) ictot,iotot
9282      format(' Total scans, obs: ', 89x,i5,1x,i5)
        else
          write(ludsp,9283) ictot,iotot
9283      format(' Total scans, obs: ', 41x,i5,1x,i5)
        endif
C
        IF  (ISORCM.GT.0) RETURN
C
      else if (ctype.eq.'PL') then !for plots
        close (90,status='keep')
C
      else if (ctype.eq.'HI') then !histogram
        write(ludsp,9301)
9301    format(' Distribution of elevations, for each station'/
     .   4x,'Elev:  0   5  10  15  20  25  30  35  40  45  ',
     .   '50  55  60  65  70  75  80  85  90')
        do i=1,nst
          j=ist(i)
          write(ludsp,9302) cstnna(j),(elhist(k,j), k=1,nbins)
9302      format(a8,': ',18i4)
          do k=1,nbins
            elhist(k,max_stn+1)=elhist(k,max_stn+1)+elhist(k,j)
          enddo
        enddo
        write(ludsp,9303) (elhist(k,max_stn+1),k=1,nbins)
9303    format(3x,'Total: ',18i4)
        tot = 0
        do i=1,nbins
          tot=tot+elhist(i,max_stn+1)
        enddo
        write(ludsp,9304) tot
9304    format('Total number of station scans: ',i5)

C       Station scans 0-10 degrees
        write(ludsp,9305)
9305    format(
     >  /,'    Elev:  0   1   2   3   4   5   6   7   8   9  10')
        do i=1,nst
          j=ist(i)
          write(ludsp,9306) cstnna(j),(elhistx(k,j), k=1,nbinsx)
9306      format(a8,': ',18i4)
          do k=1,nbinsx
            elhistx(k,max_stn+1)=elhistx(k,max_stn+1)+elhistx(k,j)
          enddo
        enddo
        write(ludsp,9307) (elhistx(k,max_stn+1),k=1,nbinsx)
9307    format(3x,'Total: ',18i4)
        tot = 0
        do i=1,nbinsx
          tot=tot+elhistx(i,max_stn+1)
        enddo
        write(ludsp,9310) tot
9310    format('Total number of station scans: ',i5)

C       Distribution of low-elevation observations
        tot=0
        do i=1,10
          tot=tot+elhistlo(i)
        enddo
        write(ludsp,9311) (elhistlo(k),k=1,10),tot
9311    format(/'Distribution of observations (one or both stations',
     .  ' are observing at low elevation)'/
     .  'Elev:  0    1    2    3    4    5    6    7    8    ',
     .  '9   10   Total'/6x,10i5,4x,i5)
        tot3=0
        tot5=0
        tot7=0
        do i=1,7
          tot7=tot7+elhistlo(i)
        enddo
        do i=1,5
          tot5=tot5+elhistlo(i)
        enddo
        do i=1,3
          tot3=tot3+elhistlo(i)
        enddo
        iptot3=100.0*tot3/float(iotot)
        iptot5=100.0*tot5/float(iotot)
        iptot7=100.0*tot7/float(iotot)
        iptot =100.0*tot /float(iotot)
        write(ludsp,9312) tot3,tot5,tot7,iptot3,iptot5,iptot7,
     .  iptot
9312    format(1x,13x,3(i5,'>>|',2x)/
     .            17x,3(i3,'%',6x),14x,i3,'%')
C
      else if (ctype.eq.'CO') then !sky coverage
        write(ludsp,9313)
9313    format(12x,'NE  SE  SW  NW  UP   Total  Avg   Rms')
        acotot=0.0
        acoto2=0.0
        do i=1,nst
          j=ist(i)
          totne = 0
          do k=1,4
            totne=totne+covhist(k,j)
          enddo
          totse = 0
          do k=6,9
            totse=totse+covhist(k,j)
          enddo
          totsw = 0
          do k=11,14
            totsw=totsw+covhist(k,j)
          enddo
          totnw = 0
          do k=16,19
            totnw=totnw+covhist(k,j)
          enddo
          totup = 0
          do k=5,20,5
            totup=totup+covhist(k,j)
          enddo
          cotot=totne+totse+totsw+totnw+totup
          acotot=acotot+cotot
          coavg=cotot/5.0
          coto2=totne*totne+totse*totse+totsw*totsw+totnw*totnw+
     .    totup*totup
          acoto2=acoto2+coto2
          corms=sqrt(coto2/5.0-coavg*coavg)
          write(ludsp,9314) cstnna(j),totne,totse,totsw,
     .    totnw,totup,cotot,coavg,corms
9314      format(a,': ',5i4,2x,3f6.0)
        enddo !station loop
        acoavg=acotot/(nst*5.0)
        acorms=sqrt(acoto2/(nst*5.0)-acoavg*acoavg)
        write(ludsp,9315) acoavg,acorms
9315    format(' Overall',5x,'Avg=',f6.0,'  Rms=',f6.0)

C  Full sky coverage histogram
        write(ludsp,9322)  
9322    format(/20x,'NE',19x,'SE',19x,'SW',19x,'NW',9x,'Avg Rms'/
     .  '  El bin: ',4(' 0  11  23  36  53  |'))
        cotot=0.0
        coto2=0.0
        do i=1,nst
          j=ist(i)
          totst=0.0
          tots2=0.0
          do k=1,ncobins
            covhist(k,max_stn+1)=covhist(k,max_stn+1)+covhist(k,j)
            cotot=cotot+covhist(k,j)
            totst=totst+covhist(k,j)
            coto2=coto2+covhist(k,j)*covhist(k,j)
            tots2=tots2+covhist(k,j)*covhist(k,j)
          enddo
          atotst=totst/ncobins
          astrms=sqrt(tots2/ncobins-atotst*atotst)
          write(ludsp,9323) cstnna(j),(covhist(k,j), k=1,ncobins),
     >       atotst,astrms
9323      format(a8,': ',4(5i4,'|'),2f4.0)
        enddo !station loop
        write(ludsp,9324) (covhist(k,max_stn+1)/nst,k=1,ncobins)
9324    format(5x,'Avg: ',4(5i4,'|'))
        acoavg=cotot/(ncobins*nst)
        acorms=sqrt(coto2/(nst*ncobins)-acoavg*acoavg)
        write(ludsp,9315) acoavg,acorms

C     Now calculate the distances between pairs of points on the sky.
      else if (ctype.eq.'CO'.or.ctype.eq.'DI') then
        write(ludsp,9414)
9414    format(/'Histogram of distances between pairs of observations',
     .  /'Values are percentages of the total number of pairs')
        write(ludsp,9412)
9412    format(/' Degrees:  0   10   20   30   40   50   60   70   80',
     .  '   90  100  110  120  130  140  150  160  170  180  #pairs') 
        do j=1,nst !station loop
          js=ist(j)
          do i=1,18
            idista(i)=0
          enddo
          do i1=1,istcnt(js)-1 ! first observation loop
            do i2=i1+1,istcnt(js) ! second observation loop
              az1=skycov(i1,1,js)
              el1=skycov(i1,2,js)
              az2=skycov(i2,1,js)
              el2=skycov(i2,2,js)
              sin1=sin(el1)
              cos1=cos(el1)
              cos2=cos(el2)
              sin2=sin(el2)
              cosd=cos(az1-az2)
              aa=sin1*sin2+cos1*cos2*cosd
              if(abs(aa).ge.1.0) then
                dista=0.0
              else
                dista=acos(sin1*sin2+cos1*cos2*cosd)*180.0/pi
              endif
              ibin=1.5+dista/10.0
              if (ibin.le.0) ibin=1
              if (ibin.gt.18) ibin=18
              idista(ibin)=idista(ibin)+1
            enddo ! second observation loop
          enddo ! first observation loop
          npairs = (istcnt(js)*(istcnt(js)-1))/2
          do i=1,18
            rdista(i)=0.5 + 100.0*idista(i)/npairs
            if (ctype.eq.'DI') write(luplt(js),9417) i*10,rdista(i)
9417        format('  1',2f10.2)
          enddo
          if (ctype.eq.'DI') then
            do i=1,18
              write(luplt(js),9419) i*10,uniform10(i)
9419          format('  1',2f10.2)
            enddo
            do i=1,18
              write(luplt(js),9418) i*10,uniform5(i)
9418          format('  1',2f10.2)
            enddo
          endif
          write(ludsp,9413) cstnna(js),(rdista(i),i=1,18), npairs
9413      format(a8,': ',18f5.1,i8)
        enddo !station loop
        write(ludsp,9415) (uniform5(i),i=1,18)
        write(ludsp,9416) (uniform10(i),i=1,18)
9415    format(105('-')/'Random5 : ',18f5.1,' (5d min. el)')
9416    format('Random10: ',18f5.1,' (10d min. el)')
C        write(ludsp,9415) (iuniform5(i),i=1,18)
C        write(ludsp,9416) (iuniform10(i),i=1,18)
C9415    format(105('-')/'Random5 : ',18i4,' (5d min. el)')
C9416    format('Random10: ',18i4,' (10d min. el)')
C     end sky coverage section

      else if (ctype.eq.'SN') then !histogram
        do ib=1,nba !bands
          iba=iband(ib)
          write(ludsp,9501) lband(iba)
9501      format(' Distribution of ',A1,'-band SNRs, for each baseline'/
     .    1x,'SNR:  0   5  10  15  20  25  30  35  40  45  ',
     .    '50  55  60  65  70  75  80  85  >>')
          do i=1,nst-1
            is=ist(i)
            do j=i+1,nst
              js=ist(j)
              ibl=ibnum(is,js)
              write(ludsp,9502) lpocod(is),lpocod(js),
     .        (isnhist(k,iba,ibl),k=1,nbins)
9502          format(1x,a2,'-',a2,':',18i4)
              do k=1,nbins
                isnhist(k,iba,max_baseline+1)=
     .          isnhist(k,iba,max_baseline+1)+isnhist(k,iba,ibl)
              enddo
            enddo
          enddo
          write(ludsp,9503) (isnhist(k,iba,max_baseline+1),k=1,nbins)
9503      format(1x,'Total',18i4)
          snrtot = 0.0
          do i=1,nbins
            snrtot=snrtot+isnhist(i,iba,max_baseline+1)
          enddo
          avgsnr=sumsnr(iba)/nsnr(iba)
          i=1
          snrtot2=0.0
          do while (i.le.nbins.and.snrtot2.lt.snrtot/2.0)
            snrtot2=snrtot2+isnhist(i,iba,max_baseline+1)
            i=i+1
          enddo
          write(ludsp,9504) snrtot,avgsnr,(i-1)*5
9504      format(1x,'Total number of obs: 'i5,'  Average SNR: ',f6.1,
     .          '   Median SNR bin: ',i3)
        enddo
      else if (ctype.eq.'BA') then !baseline summary
        isssum=0
        DO  I=1,NSOURC !display
          IF (ISORCM.EQ.0.OR.(ISORCM.GT.0.AND.I.EQ.ISORCM)) THEN !show this one
            WRITE(LUDSP,9401) cSORNA(I)
9401        FORMAT(1X,A8,$)
            issum=0
            do j=1,nst-1
              js=ist(j)
              do k=j+1,nst
                ks=ist(k)
                ib=ibnum(js,ks)
                write(ludsp,9402) ibcount(i,ib)
9402            format(i4,$)
                ibsum(ib)=ibsum(ib)+ibcount(i,ib)
                issum=issum+ibcount(i,ib)
              enddo
            enddo
          write(ludsp,9403) issum
9403      format(i4)
          isssum=isssum+issum
          endif
        enddo 
        write(ludsp,'(" Total   ",$)')
        do j=1,nst-1
          js=ist(j)
          do k=j+1,nst
            ks=ist(k)
            ib=ibnum(js,ks)
            write(ludsp,9402) ibsum(ib)
          enddo
        enddo
        write(ludsp,'(i4)') isssum
      endif !display
C
      if (ctype.eq.'AZ'.or.ctype.eq.'EL'.or.ctype.eq.'XY'.
     .  or.ctype.eq.'PO'.or.ctype.eq.'DI') then !finish the plot
        kvis = .false.
        call sumpl(ctype,nst,ist,xmin,xmax,ymin,ymax,luplt,istcnt,kvis)
      endif
C
C   7. Write out statistics.
C
      if (ctype.eq.'LI'.or.ctype.eq.'BA'.or.ctype.eq.'ST') then !statistics display
        davgr = davgr/dble(nvarn)
        dvar = (davgs/dble(nvarn)) - davgr*davgr
C       write(ludsp,9405) davgr,dminnob,dmaxnob,lstcod(njdmax),
        if (njdmax.gt.0) 
     .  write(ludsp,9405) davgr,dminnob,dmaxnob,lpocod(njdmax),
     .  lpocod(nkdmax),csorna(nsdmax),dsqrt(dvar)
9405    format(/' Average number of obs. per baseline',
     .  ' per source (normalized by up-time) = ',f5.1/
     .  ' Min = ',f5.1,'   Max = ',f6.1,' (Baseline ',a2,'-',a2,
     .  ' on ',a8,')   RMS = ',f5.1)
        WRITE(LUDSP,9316)ITTIME,ittime/60.0
 9316   FORMAT(/' Total time: ',I10,' minutes (',f5.1,' hours).'/)
        write(ludsp,'(" Key:  ",$)')
        DO  I = 1,NST
          J = IST(I)
C         write(ludsp,9317) lstcod(j),(lantna(ii,j),ii=1,4)
          write(ludsp,9317) lpocod(j),cantna(j)
9317      format(3x,a2,'=',a8,$)
          if (mod(i,5).eq.0) write(ludsp,'(/,7x,$)')
          POBS(J)=100.0*((SITOBS(J)/60.0)/(ITTIME+0.0))
          dobs(j)=0
          dgb(j)=0.d0
          if (istcnt(j).gt.0) dobs(j)=sitobs(j)/istcnt(j)
C         Calculate GB recorded per station, using sample rate for code 1 ONLY
          num_mk5_tracks=ntrkn(1,j,1)+ntrkn(2,j,1)
          ipow2=4
          do while(num_mk5_tracks .ne. ipow2 .and. ipow2 .le. 64)
            if(num_mk5_tracks .lt. ipow2) then
               num_mk5_tracks=ipow2
            endif
            ipow2=ipow2*2
          endif

          trate=samprate(1)*num_mk5_tracks
          dgB(j) = sitobb(j)*trate*(1./8.0d3) ! convert to bytes.
          PCAL(J)=100.0*((SITCAL(J)/60.0)/(ITTIME+0.0))
          PSLW(J)=100.0*((TSLW(J)/60.)/(ITTIME+0.0))
          PIDLE(J)=100.0-POBS(J)-PCAL(J)-PSLW(J)
        END DO 
        write(ludsp,'(/)')
        WRITE(LUDSP,9318) (lpocod(IST(I)),I=1,NST)
9318    FORMAT(18X,15(A2,3X,$))
        write(ludsp,'("Avg")')
        apobs=0.0
        apcal=0.0
        apslw=0.0
        apidle=0.0
        iastcnt=0
        ianh=0
        iadobs=0
        iadgB=0
        adgB=0.d0
        tottapes=0.0
        do i=1,nst ! calculate fractions
          j=ist(i)
          apobs=apobs+pobs(j)
          apcal=apcal+pcal(j)
          apslw=apslw+pslw(j)
          apidle=apidle+pidle(j)
          iastcnt=iastcnt+istcnt(j)
          ianh=ianh+istcnt(j)*60/ittime
          iadobs=iadobs+dobs(j)
          iadgB=iadgB+dgB(j)
          adgB=adgB+dgB(j)
          fdgB(j)=dgB(j)/960.d0 ! number of 8-pk of 120 GB disks
          fntapes(j)=float(ipascur(j))/float(maxpas(j)*npassf(j,1)) !fraction
          if (ntapes(j).gt.0) fntapes(j)=fntapes(j)+float(ntapes(j))
C             fractional number of tapes is the pass number over the
C             total number of indexes (i.e. maxpas) times the number 
C             of sub-passes per index position.
          tottapes=tottapes+fntapes(j)
          do k=1,max_change_list ! calculate hh:mm tape change times
            tphr(k,j) = tape_change_time(k,j)/3600.d0
            tpmn(k,j) = (tape_change_time(k,j) - 
     .                   tphr(k,j)*3600.d0)/60.d0
          enddo ! calculate hh:mm tape change times
        enddo ! calculate fractions
        WRITE(LUDSP,9360) (POBS(IST(I)),I=1,NST),apobs/nst
        WRITE(LUDSP,9370) (PCAL(IST(I)),I=1,NST),apcal/nst
        WRITE(LUDSP,9380) (PSLW(IST(I)),I=1,NST),apslw/nst
        WRITE(LUDSP,9385) (PIDLE(IST(I)),I=1,NST),apidle/nst
9360    FORMAT(1X,'% obs. time:',3X,21(1X,I4))
9370    FORMAT(1X,'% cal. time:',3X,21(1X,I4))
9380    FORMAT(1X,'% slew time:',3X,21(1X,I4))
9385    FORMAT(1X,'% idle time:',3X,21(1X,I4))
9320    FORMAT(1X,'total # scans: ',21(1X,I4))
9325    FORMAT(1X,'# scans/hour : ',$)
9333    format(1x,'Avg scan (sec):',21(1x,i4))
9334    format(1x,'Total GBytes:  ',21(1x,i4))
9335    format(1x,'# of 8-packs:',2x,21(f5.1))
9319    FORMAT(1X,'# of tapes :',3x,21(f5.1))
        WRITE(LUDSP,9320) (ISTCNT(IST(I)),I=1,NST),iastcnt/nst
        write(ludsp,9325)
        WRITE(LUDSP,'(1x,i4,$)') (ISTCNT(IST(I))*60/ittime,I=1,NST)
        write(ludsp,'(1x,f4.1)') float(iastcnt)/(float(nst)*24.0)
        write(ludsp,9333) (dobs(ist(i)),i=1,nst),iadobs/nst
        write(ludsp,9334) (dgB(ist(i)),i=1,nst),iadgB/nst
        WRITE(LUDSP,9335) (fdgB(IST(I)),I=1,NST)
        WRITE(LUDSP,9319) (fNTAPES(IST(I)),I=1,NST)
C       Tape change times
        write(ludsp,9321)
9321    format(1x,'tape change times (hhmm):')
        do k=1,max_change_list
          write(ludsp,'(16x,$)')
          kmore = .false.
          do i=1,nst
            j=ist(i)
            kmore = kmore.or.(tphr(k,j).gt.0.or.tpmn(k,j).gt.0)
          enddo
          if (kmore) then ! another row of times
            do i=1,nst
              j=ist(i)
              write(ludsp,93211) tphr(k,j),tpmn(k,j)
93211         format(1x,i2.2,i2.2,$)
            enddo
            write(ludsp,'(1x)')
          endif ! another row of times
        enddo
        if (ntapes(j).gt.max_change_list) then
          write(ludsp,9399) ntapes(j),max_change_list
9399      format("NOTE: This schedules uses ",i3," tapes. Tape",
     .    "changes times are listed for the first ",i3," tapes.")
        endif
        write(ludsp,9331) tottapes,adgB
9331    format(/"Total number of tapes: ",f5.1,"  Total GBytes ",
     .  "recorded: ",f7.1)
        WRITE(LUDSP,9330)
9330    FORMAT(/6X,'# OF OBSERVATIONS BY BASELINE'/)
        CALL IFILL(LINES,1,ILIN*2,oblank)
        ICN = ichmv_ch(LINES,1,'  | ')
        DO  I = 1,NST
          ICN = ICHMV(LINES,ICN,lpocod(IST(I)),1,2)+2
        END DO
        idummy = ichmv_ch(lines,icn+1,'StnTotal')
        INUM = (ICN+1)/2
        WRITE(LUDSP,9390) (LINES(IP),IP=1,INUM+4)
9390    FORMAT(1X,120a2)
        CALL IFILL(LINES,1,ILIN*2,OMINUS)
        WRITE(LUDSP,9390) (LINES(IP),IP=1,INUM+4)
        IC=1
        ITOT=0
        DO  I=1,NST
          IJ = IST(I)
          CALL IFILL(LINES,1,ILIN*2,oblank)
          ICN = ICHMV(LINES,1,lpocod(IJ),1,2)
          ICN = ichmv_ch(LINES,ICN,'|')
          idummy = IB2AS(ISTCNT(IST(I)),LINES,4*I,3)
          IF  (I.NE.NST) THEN
            DO  J = 1,NST-I
              ii=j+i
              ic=ibnum(ist(i),ist(ii))
              idummy = IB2AS(IBSELN(IC),LINES,4*(J+I),3)
              ITOT=ITOT+IBSELN(IC)
C             IC = IC+1
            END DO 
          END IF 
          ibst=0
          do j=1,nst
            if (i.ne.j) ibst=ibst+ibseln(ibnum(ij,ist(j)))
          enddo
          idummy = ib2as(ibst,lines,inum*2+2,4)
          WRITE(LUDSP,9390) (LINES(IP),IP=1,INUM+3)
        END DO 
        write(ludsp,'(/)')
        do i=2,nstatn
          write(ludsp,9396) i,ibnumob(i)
9396      format(' Number of ',i2,'-station scans: 'i4)
        enddo
        WRITE(LUDSP,9395) IcTOT,iotot
9395    FORMAT(/' Total # of scans, observations: 'I5,3x,i5/)
C       write(ludsp,9397)
C9397    format(/' Average baseline components for all observations')
C       write(ludsp,9398) busum/(1000.d0*float(iotot)),
C     .  bxsum/(1000.d0*float(iotot)),
C     .  bysum/(1000.d0*float(iotot)),blsum/(float(iotot))
C9398    format('  Average XY     = ',f5.0/
C     .         '  Average XZ     = ',f5.0/
C     .         '  Average YZ     = ',f5.0/
C     .         '  Average length = ',f5.0/)
      endif !statistics display

      RETURN
      END
