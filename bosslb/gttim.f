      subroutine gttim(ias,ifc,iec,imode,it1,it2,it3,ierr)
C 
C     GTTIM 
C 
C 1.  GTTIM PROGRAM SPECIFICATION 
C 
C 1.1.   GTTIM decodes the SNAP time formats
C 
C 1.2.   RESTRICTIONS - limits on use of routine
C 
C 1.3.   REFERENCES - document cited
C 
C 2.  GTTIM INTERFACE 
C 
C 2.1.   CALLING SEQUENCE: CALL GTTIM(   see above        ...)
C 
C     INPUT VARIABLES:
C 
      integer*2 ias(1)
C               - string array
C        IFC,IEC- first, last characters of time format in IAS
C        IMODE  - 0 - both date and time wanted 
C                 1 - only time allowed 
C                 2 - only date allowed (not implemented) 
C 
C     OUTPUT VARIABLES: 
C 
C        IT1    - first word of time, (YR-1970)*1024+DAY
C        IT2    - second word of time, HR*60+MIN
C        IT3    - third word, SEC*100+MSEC/10 
C        IERR   - error return, 0=all OK
C 
C 2.2.   COMMON BLOCKS USED 
C 
C 2.3.   DATA BASE ACCESSES 
C 2.4.   EXTERNAL INPUT/OUTPUT
C 
C 2.5.   SUBROUTINE INTERFACE:
C 
C     CALLING SUBROUTINES: SPARS, TMLIS 
C 
C     CALLED SUBROUTINES: ICHMV,IAS2B,ISCNC 
C 
C 3.  LOCAL VARIABLES 
C 
C        CLEC    - last character of IAS 
C        ILEN   - length of time field, IEC-IFC+1 
C        ICD    - character position of decimal point 
C        NFPC   - number of characters beyond decimal point 
C        NDATC  - number of characters in date part of time field 
C        ICH    - scan character
C        ICHX   - place-keeping scan character
C        NSCAN  - number of char scanned so far 
C        ICHM   - month scan character
C        ICHD   - day scan character
C        IHR    - hours 
C        IMIN   - minutes 
C        ISEC   - seconds 
C        IFSEC  - fractional seconds
C        IHSEC  - hundredths of seconds 
C        IYR    - year
C        IMON   - month 
C        IDAY   - day 
      character clec,cjchar
      dimension ndays(12) 
C               - number of days in year at beginning of each month 
      integer*2 isuf(6)
C               - suffixes to be scanned for
      dimension ifld(3) 
C               - H,M,S fields
      dimension frac(3) 
C               - possible fractional part of H,M,S 
      integer ict(6),idacur,iyrcur
C                   -CURRENT TIME (FROM EXEC(11)) 
C 
      equivalence (ict(5),idacur),(ict(6),iyrcur) 
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ndays/0,31,59,90,120,151,181,212,243,273,304,334/
      data isuf/2H y,2H m,2H d,2H h,2H m,2H s/
C---------------------- TEMPORARY FIX---------------------
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED: CREATED 781204 
C# LAST COMPC'ED  870115:04:21 #
C 
C     PROGRAM STRUCTURE 
C 
C     1. Initialize.  Check last character: if numeric, we have 
C     the fully numeric format, otherwise suffixes. 
C 
      call fc_rte_time(ict(1),ict(6)) 
      it1 = 0 
      it2 = 0 
      it3 = 0
      iyr = 0
      imon = 0
      iday = 0
      do 100 i=1,3
        ifld(i) = 0
        frac(i) = 0.0
100     continue
      ierr = 0
      if(cjchar(ias,ifc).eq.',') then
        ierr=-8
        goto 999
      endif
      clec = cjchar(ias,iec)
      ilen = iec-ifc+1
      if (cjchar(ias,ifc).ne.'!') goto 190
      it1 = -1
C                   We have a ! so indicate NOW
      goto 999
C
190   if (index('0123456789',clec).eq.0) goto 500
      if(iscn_ch(ias,ifc,iec,':').ne.0) goto 560
C
C     2. Fully numeric format.  Locate the
C     decimal point, if any, and pull off seconds, minutes, then
C     hours from the right.
C     General format is:
C                 yyyymmddhhmmss.sss
C                 \------/\----/\--/
C                    date  time  fraction 
C # chars each:      NDATC   6   NFPC 
C 
C 
      icd = iscn_ch(ias,ifc,iec,'.')
C                    Scan for decimal point 
      if (icd.eq.0) icd = iec + 1 
      nfpc = iec - icd + 1
C                   Number of digits past decimal point, INCL . 
      ndatc = ilen - (6+nfpc) 
C                   Number of digits in date field
      if (ndatc.ge.0.and.imode.eq.0) goto 300 
      if (ndatc.eq.0.and.imode.eq.1) goto 300 
C                   If we want both date and time (IMODE=0) go on.
      if (ndatc.lt.0               ) ierr=-5
      if (ndatc.gt.0.and.imode.eq.1) ierr=-9
      goto 999
C 
C 
C     3.  Decode H, M, S now.  Start from decimal point and 
C     proceed to the left.
C 
300   ifsec = 0 
      if (nfpc.gt.0) ifsec = ias2b(ias,icd+1,nfpc-1)
      ihsec = ifsec*10**(3-nfpc)
C                   Hundredths of sec = (fraction/10^nfp-1)*10^2
      isec = ias2b(ias,icd-2,2) 
      imin = ias2b(ias,icd-4,2) 
      ihr  = ias2b(ias,icd-6,2) 
      goto 400
C 
C 
C     4. Date field section.  Handle according to:
C     NDATC = 8 implies we have    yyyymmdd 
C             7                    yyyyddd
C             4                    mmdd (assume current year) 
C           <=3                    ddd, dd or d (day number, assume 
C                                               current year) 
C 
400   if (ndatc.eq.0) goto 600
C 
410   if (ndatc.lt.5) goto 420
C 
C     4.1 Here we have the year specified.
C 
c not Y10K compliant
      iyr = ias2b(ias,ifc,4)
c not Y10K compliant
      if (ndatc.eq.8) imon = ias2b(ias,ifc+4,2) 
c not Y10K compliant
      if (ndatc.eq.8) iday = ias2b(ias,ifc+6,2) 
c not Y10K compliant
      if (ndatc.eq.7) iday = ias2b(ias,ifc+4,3) 
      goto 600
C 
C     4.2 Here we have no year. 
C 
420   if (ndatc.eq.4) imon = ias2b(ias,ifc,2) 
      if (ndatc.eq.4) iday = ias2b(ias,ifc+2,2) 
      if (ndatc.le.3) iday = ias2b(ias,ifc,ndatc) 
      goto 600
C 
C     5. Alternate format time, with suffixes.
C 
500   nscan = 0 
      ichx = ifc-1
      ich = iscnc(ias,ifc,iec,jchar(isuf(1),2))
      if (ich.eq.0) goto 510
      if (ich.ne.ifc+4) goto 590
C                   The "Y" must be the fifth character (first field) 
c not Y10K compliant
      iyr = ias2b(ias,ifc,4)
      nscan = nscan + ich - ichx
      ichx = ich
510   ichd = iscnc(ias,ichx+1,iec,jchar(isuf(3),2))
      if (ichd.eq.0) goto 520 
      ichm = iscnc(ias,ichx+1,iec,jchar(isuf(2),2))
      if (ichm.gt.ichd.or.ichm.eq.0) goto 515 
      imon = ias2b(ias,ichx+1,ichm-ichx-1)
      nscan = nscan + ichm - ichx 
      iday = ias2b(ias,ichm+1,ichd-ichm-1)
      nscan = nscan + ichd - ichm 
      goto 519
515   iday = ias2b(ias,ichx+1,ichd-ichx-1)
      nscan = nscan + ichd - ichx 
519   ichx = ichd 
520   do 530 i=1,3
         ich = iscnc(ias,ichx+1,iec,jchar(isuf(i+3),2)) 
         if (ich.eq.0) goto 530
         ifld(i) = numsc(ias,ichx+1,ich-1,frac(i)) 
         nscan = nscan + ich - ichx
         ichx = ich
         if (frac(i).ne.0.or.ichx.eq.iec) goto 540 
 530  continue
 540  continue
      if (nscan.ne.iec-ifc+1) goto 590
      ihr = ifld(1) 
      ifrac = int(frac(1)*60.0) 
C                   Minutes in the fractional part of hour
      imin = ifld(2) + ifrac
      frac(2) = frac(2) + (frac(1)*60.0 - ifrac)
      ifrac = int(frac(2)*60.0) 
C                   Seconds in the fractional part of minutes 
      isec = ifld(3) + ifrac
      frac(3) = frac(3) + (frac(2)*60.0 - ifrac)
      ihsec = frac(3)*100.0+0.5 
C 
      goto 600
C
C  alternate format with separators
C
 560  continue
      nscan = 0
      ichx=ifc-1
      icln=iscn_ch(ias,ifc,iec,':')
      ich =iscn_ch(ias,ifc,iec,'.')
c not Y10K compliant
      if(ich.eq.ifc+4) then
c not Y10K compliant
         iyr = ias2b(ias,ifc,4)
         nscan = nscan + ich - ichx
         ichx = ich
      endif
C
      ichm=iscn_ch(ias,ichx+1,icln,'.')
      if(ichm.eq.0) go to 570
      ichd=iscn_ch(ias,ichm+1,icln,'.')
      if(ichd.eq.0) then
         ichd = ichm
         iday = ias2b(ias,ichx+1,ichd-ichx-1)
         nscan = nscan + ichd - ichx 
      else
         imon = ias2b(ias,ichx+1,ichm-ichx-1)
         nscan = nscan + ichm - ichx 
         iday = ias2b(ias,ichm+1,ichd-ichm-1)
         nscan = nscan + ichd - ichm 
      endif
      ichx=ichd
 570  continue
      do i=1,3
         if(i.lt.3) then
            ich = iscn_ch(ias,ichx+1,iec,':') 
         else
            ich=iec+1
         endif
         if (ich.gt.ichx+1) then
            ifld(i) = numsc(ias,ichx+1,ich-1,frac(i))
            if(i.eq.3) ich=ich-1
         endif
         nscan = nscan + ich - ichx
         ichx = ich
         if (frac(i).ne.0.or.ichx.eq.iec) goto 575 
      enddo
 575  continue
      goto 540

590   ierr = -8 
      goto 999
C 
C 
C     6. Check range for H,M,S.  Set up current values for year and 
C     month if not specified.  Check range for Y,M,D. 
C     If all is OK, set up IT fields. 
C 
600   continue
      if (iyr.eq.0.and.iday.ne.0.and.iday+1.lt.idacur) goto 660
      if (iyr.eq.0) iyr = iyrcur
      if (iyr.lt.1970.or.iyr.gt.2038) goto 650 
      if (iday.eq.0) iday = idacur
      if (imon.lt.0.or.imon.gt.12) goto 650 
      if (iday.lt.0.or.iday.gt.366) goto 650
C 
      if (ihr.lt.0.or.ihr.gt.23) goto 650 
      if (imin.lt.0.or.imin.gt.59) goto 650 
      if (isec.lt.0.or.isec.gt.59) goto 650 
      if (ihsec.lt.0.or.ihsec.gt.99) goto 650 
C 
      if (imon.eq.0) goto 610 
      iday = iday + ndays(imon) 
C                   If month was specified, change to day of year 
c not Y2.1K compliant
      if (mod(iyr,4).eq.0.and.iday.gt.59) iday = iday+1 
C                   Leap year 
C 
610   it1 = (iyr-1970)*1024 + iday
      it2 = ihr*60 + imin 
      it3 = isec*100 + ihsec
C 
      goto 999
C 
650   ierr = -7 
      goto 999
C
 660  continue
      ierr= -14
      goto 999
C 
999   return
      end 
