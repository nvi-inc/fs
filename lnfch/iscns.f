      function iscns(input,icst,icen,icomp,icomst,nch)
C 
C  ISCNS scans a string for the occurence of another string 
C 
C  ISCNS INTERFACE 
C 
C  INPUT VARIABLES:
C 
C        ICST   - starting character in INPUT 
C        ICEN   - last character in INPUT 
C        ICOMST - starting character in ICOMP 
C        NCH    - number of characters to compare 
      integer*2 input(1),icomp(1) 
C               - input string array, compare string array
C 
C  OUTPUT VARIABLES: 
C 
C        ISCNS - returns character in INPUT at which compare
C                string ICOMP begins
C 
C  SUBROUTINE INTERFACE:
C 
C  CALLING SUBROUTINES: utility
C  CALLED SUBROUTINES: ISCNC, ICHCM, JCHAR from Lee's package
C 
C  LOCAL VARIABLES 
C 
C        ICH    - general character counter 
C        ISC    - character found in scan 
C 
C  PROGRAMMER: NRV 
C  LAST MODIFIED:
C# LAST COMPC'ED  870407:12:47 #
C 
C  SCAN FOR THE OCCURENCE OF THE FIRST CHARACTER IN ICOMP
C 
      ich = icst
100   if (icen-ich+1.ge.nch) goto 101 
      isc = 0 
      goto 990
101   continue
      call pchar(idum,2,jchar(icomp,icomst))
      isc = iscnc(input,ich,icen,idum) 
C 
C  IF THIS CHARACTER NOT FOUND, RETURN ZERO FOR NO MATCH 
C 
      if (isc.eq.0) goto 990
C 
C  NOW COMPARE THE INPUT STRING WITH THE COMPARE STRING
C 
      ich = ichcm(input,isc,icomp,icomst,nch) 
C 
C  IF THE STRINGS MATCH WE ARE DONE, SO RETURN THE STARTING CHARACTER
C 
      if (ich.eq.0) goto 990
C 
C  UPDATE THE FIRST CHARACTER TO USE IN THE SCAN AND LOOP BACK 
C 
      ich = isc + 1 
      goto 100
C 
990   iscns = isc 

      return
      end 
