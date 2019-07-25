      subroutine gtradd(ias,ic1,ic2,imode,rad,ierr)
C  get ra,dec formats c#870115:04:30# 
C 
      include '../include/dpi.i'
C
C 1.1.   GTRADD decodes the SNAP ra, dec formats 
C 
C     INPUT VARIABLES:
C 
      integer*2 ias(1)
C               - string array
C        IC1,IC2 - first, last characters of time format in IAS 
C        IMODE  - mode allowed for input characters 
C                 1 = RA
C                 2 = DEC with limits +/-90 
C                 3 = RA offsets (can be negative)
C                 4 = degrees, limits +/-360
C 
C     OUTPUT VARIABLES: 
C 
      double precision rad
C        RAD - value of angle, in radians 
C        IERR   - error return, 0=all OK
C 
C     CALLING SUBROUTINES: SORCE
C 
C     CALLED SUBROUTINES: ICHMV,IAS2B
C 
C 3.  LOCAL VARIABLES 
C 
      double precision das2b
C        LEC    - last character of IAS 
C        ICD    - character position of decimal point 
C        NFPC   - number of characters beyond decimal point 
C        ICH    - scan character
C        ICHX   - place-keeping scan character
C        NSCAN  - number of char scanned so far 
C        IHR    - hours 
C        IMIN   - minutes 
C        ISEC   - seconds 
C        IFSEC  - fractional seconds
cxx      dimension isuf(2)
      integer*2 isuf(2)
C               - suffixes to be scanned for
      dimension fld(3)
C               - H,M,S values
      character cjchar
C
C 4.  CONSTANTS USED
C
C 5.  INITIALIZED VARIABLES
C
C
C 6.  PROGRAMMER: NRV
C     LAST MODIFIED: CREATED 800216
C# LAST COMPC'ED  870115:04:30 #
C
C
C     1. Initialize.  Check last character: if numeric, we have
C     the fully numeric format, otherwise suffixes.
C
      call char2hol('hms ',isuf,1,4)
      ierr = 0
      rad = 0.0d0
      ifc = ic1
      iec = ic2
      idumm1 = ichmv_ch(isuf,1,'h')
      if (imode.eq.2.or.imode.eq.4) idumm1 = ichmv_ch(isuf,1,'d')
C                   If declination, change first suffix to "D"
      do 100 i=1,3
        fld(i) = 0.0
100     continue
C
      lfc = jchar(ias,ifc)
      isign = +1
      if (lfc.ne.o'53'.and.lfc.ne.o'55') goto 190
C                   If there is no sign, no work needs to be done
      if (imode.ne.1) goto 180
      ierr = -3
C                   The RA cannot be negative unless it is an offset! 
      goto 999
180   ifc = ifc + 1 
C                   Skip over the sign
      if (lfc.eq.o'55') isign = -1
C                   Remember the sign for signing the value at the end
190   lec = jchar(ias,iec)
      if ((lec.lt.o'60'.or.lec.gt.o'71').and.lec.ne.o'56') goto 500 
C                   If last char is non-numeric AND not a "." 
C                   we must have some suffixes
C 
C 
C     2. Fully numeric format.  Locate the
C     decimal point, if any, and pull off seconds, minutes, then
C     hours from the right. 
C     General format is:
C                   hhmmss.sss
C                   \----/\--/
C                    time  fraction 
C # chars each:        6   NFPC 
C 
C 
      icd = iscn_ch(ias,ifc,iec,'.')
C                    Scan for decimal point 
      if (icd.eq.0) icd = iec + 1 
      nfpc = iec - icd + 1
C                   Number of digits past decimal point, INCL . 
      if (icd-6.ge.ifc) goto 300
      ierr = -1 
      goto 999
C                   Must use suffixes if not completely specified 
C 
C 
C     3.  Decode H, M, S now.  Start from decimal point and 
C     proceed to the left.
C 
300   fld(3)= das2b(ias,icd-2,nfpc+2,ierr)
      imin = ias2b(ias,icd-4,2) 
      ihr  = ias2b(ias,icd-6,2) 
      if (ierr.ne.0.or.imin.eq.-32768.or.ihr.eq.-32768) goto 390
      fld(1) = ihr
      fld(2) = imin 
      goto 600
C 
390   ierr = -2 
      goto 999
C 
C 
C     5. Alternate format time, with suffixes.
C 
500   nscan = 0 
      ichx = ifc-1
520   do 530 i=1,3
        ich = iscn_ch(ias,ichx+1,iec,cjchar(isuf,i)) 
        if (ich.eq.0) goto 530
        fld(i) = das2b(ias,ichx+1,ich-ichx-1,ierr)
        if (ierr.ne.0) goto 590 
        nscan = nscan + ich - ichx
        ichx = ich
        if (ichx.ge.iec) goto 600 
530     continue
C 
C 
590   ierr = -8 
      goto 999
C 
C 
C     6. Check range for H,M,S. 
C     If all is OK, compute value in radians. 
C 
600   if (imode.eq.1.and.(fld(1).lt.0.0.or.fld(1).gt.24.0)) goto 650
      if (imode.eq.2.and.(fld(1).lt.0.0.or.fld(1).gt.90.0)) goto 650
      if (imode.eq.4.and.(fld(1).lt.0.0.or.fld(1).gt.360.0)) goto 650 
      if (fld(2).lt.0.0.or.fld(2).gt.60.0) goto 650 
      if (fld(3).lt.0.0.or.fld(3).gt.60.0) goto 650 
C 
      fac = 1.0 
      if (imode.eq.2.or.imode.eq.4) fac = 15.0
      rad = isign*(fld(1)*3600.0d0+fld(2)*60.0d0+fld(3))* 
     .      DPI/(3600.0d0*12.0d0*fac)
C 
      goto 999
C 
650   ierr = -7 
C 
999   return
      end 
