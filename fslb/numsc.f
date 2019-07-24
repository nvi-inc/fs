      function numsc(ias,ifc,iec,frac)
C 
C  NUMSC scans an ASCII string and returns integer and fraction 
C 
C  CALLING SEQUENCE: CALL NUMSC(III,III,...,OOO,OOO,...)
C 
C  INPUT VARIABLES:
C 
C        IFC    - first character in string to be scanned 
C        IEC    - last character in string to be scanned
      dimension ias(1)
C               - ASCII string to be scanned
C 
C  OUTPUT VARIABLES: 
C 
C        FRAC   - fractional part, if any, found in string
C        NUMSC  - integer part of number
C 
C  CALLING SUBROUTINES:
C  CALLED SUBROUTINES: IAS2B,ISCNC 
C 
C  LOCAL VARIABLES 
C 
C        IDC    - character index of decimal point
C 
C  PROGRAMMER: nrv 
C  LAST MODIFIED:   781206 
C# LAST COMPC'ED  870407:12:43 #
C 
C  First find the decimal point, if any.
C  Then decode the integer part of the number. 
C  Finally decode the fraction, if any.
C 
      idc = iscn_ch(ias,ifc,iec,'.')
      if (idc.eq.0) idc = iec + 1 
      numsc = ias2b(ias,ifc,idc-ifc)
      frac = 0.0
      if (idc.eq.iec+1) goto 99 
      frac = ias2b(ias,idc+1,iec-idc) 
      frac = frac/(10.0**(iec-idc)) 

99    return
      end 
