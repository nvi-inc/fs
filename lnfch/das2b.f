      double precision function das2b(ias,ic1,nch,ierr)
C     ascii to double precision binary
C 
C     THIS FUNCTION CONVERTS AN ASCII STRING TO DOUBLE PRECISION
C 
C     INPUT PARAMETERS: 
C 
      integer*2 ias(1)
C                   INPUT STRING WITH ASCII CHARACTERS
C     IC1 - FIRST CHARACTER TO USE IN IAS 
C     NCH - NUMBER OF CHARACTERS TO CONVERT 
C     IERR - ERROR RETURN, 0 IF OK, -1 IF ANY CHARACTER IS NOT A NUMBER 
C 
C     LOCAL VARIABLES 
C 
C     IFC - FIRST CHARACTER WHICH IS NOT + OR - 
C     IEC - LAST CHARACTER TO BE CONVERTED
C     IDC - CHARACTER NUMBER OF DECIMAL POINT 
C     NCINT - NUMBER OF CHARACTERS IN INTEGER PART
C     ISIGN - +1 OR -1
      character cjchar
      double precision val
C                   VALUE BUILT UP DURING SCAN OF CHARACTERS
C     IEXP - EXPONENT FOR SCALING 
C 
C 
C     SET UP THE CHARACTER COUNTERS NEEDED.  FIND THE DECIMAL POINT.
C     DETERMINE THE SIGN OF THE NUMBER. 
C 
      ierr = 0
      ifc = ic1 
      if(ifc.le.0) goto 990
      iec = ifc + nch - 1 
      if(ifc.gt.iec) goto 990
      if (cjchar(ias,ic1).eq.'-'.or.cjchar(ias,ic1).eq.'+') 
     .  ifc = ifc + 1 
      idc = iscn_ch(ias,ifc,iec,'.')
      if (idc.eq.0) idc = iec + 1 
      ncint = idc - ifc 
      isign = +1
      if (cjchar(ias,ic1).eq.'-') isign = -1 
C 
C     CONVERT THE CHARACTERS IN THE INTEGER PART
C 
      val = 0.d0
      if (ncint.eq.0) goto 200
      do 100 i=ifc,idc-1
        if (cjchar(ias,i).lt.'0'.or.cjchar(ias,i).gt.'9') goto 990
        iexp = idc - i - 1
        idum = ias2b(ias,i,1) 
        val = val + ias2b(ias,i,1)*10.d0**iexp
100     continue
C 
C     CONVERT THE CHARACTERS FOLLOWING THE DECIMAL POINT
C 
200   if (idc.ge.iec) goto 980
      do 201 i = idc+1, iec 
        if (cjchar(ias,i).eq.'D'.or.cjchar(ias,i).eq.'E') goto 300
        if (cjchar(ias,i).eq.'d'.or.cjchar(ias,i).eq.'e') goto 300
        if (cjchar(ias,i).lt.'0'.or.cjchar(ias,i).gt.'9') goto 990
        val = val + ias2b(ias,i,1)*10.d0**(idc-i) 
      idum=ias2b(ias,i,1) 
      iexp = idc-i
201     continue
      goto 980
C 
C     TAKE CARE OF THE EXPONENT FOUND AFTER THE "D" OR "E"
C 
300   iexp = ias2b(ias,i+1,iec-i) 
      val = val*10.d0**iexp 
C 
C     FINISH UP NOW 
C 
980   das2b = val*isign 
      return
C 
C     HANDLE ERRORS HERE
C 
990   ierr = -1 
      das2b = 0.d0
      return
      end 
