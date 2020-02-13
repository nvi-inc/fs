      function ir2as(value,ias,ifc,nchtot,ncfrac)

! AEM 20050112 add implicit none,list variables
      IMPLICIT NONE
      integer ir2as

C     This function converts a real number to ASCII format
C 
C 
C  INPUT:
C 
C     VALUE - real value to be converted
cxx      dimension ias(1)
      real*4 value 
      integer*2 ias(*)
      integer ifc,nchtot,ncfrac

C      - string array for ASCII value 
C     IFC - first character to use in IAS
C     NCHTOT - maximum number of characters in field
C              >0 for left-justify, <0 for right-justify
C     NCFRAC - number of characters in fraction, i.e. following
C              decimal point.  >0 for leading spaces, <0 leading zeros
C     **NOTE: NCHTOT and NCFRAC are similar in function to the two
C     digits n and m used in the FORTRAN format Fn.m, respectively. 
C 
C  OUTPUT:
C 
C     IR2AS - number of characters used in formatting value 
C 
C 
C  SUBROUTINES: 
C
C     Character manipulation ICHMV, IB2AS 
C
C 
C  LOCAL: 
C 
      double precision val
C     VAL - absolute value of VALUE 
      double precision valint
C     VALINT - integer part, as number is being built up
C     IDIGIT - current digit being added to number
C     NDIG - set to 1 once leading zeros are passed over
C     IC - current character in output string 
C     IDEC - number of characters following decimal point 
C     NCI - number of characters requested for integer part 
C     IX - number of spaces pre-empted by "-" or "."
C
      integer nch,ncfr,llead,i,ix,nci,ic,ndig,idec,idigit
      integer ichmv_ch,ichmv,ib2as
C
C     1. First initialize the counters and indices.
C 
      nch = iabs(nchtot)
C  The total number of characters we can use 
      ncfr = iabs(ncfrac)
C  The number of characters in the fractional part 
      call char2hol('  ',llead,1,2)
      if (ncfrac.lt.0) call char2hol('00',llead,1,2)
C  Establish the character for leading blanks or zeros 
      val = abs(value)+0.5*0.1**ncfr
C  The value to be converted
      valint = 0.0d0
C  The integer part of the number so far
      ix = 1
C  We expect to exclude one space for a decimal point
      if (value.lt.0.0) ix = 2
C  We might have a sign to include,
C  so need to pre-empt another space
C     IF (NCFR.EQ.0) IX=IX-1
C  Maybe no decimal point is wanted at all 
C     We can't handle the no-decimal point case easily, so skip it
      nci = nch-ncfr-ix 
C  So, the number of characters in the INTEGER
C  part of the number is the total less the number 
C  in the fraction and the number for . and/or - 
      if (nci.eq.0) goto 300
C  If we won't have any room for the integer 
C  part of the number, go fill with $$ 
      ic = ifc
C  Start character counter where requested 
      if (value.lt.0.0.and.ncfrac.lt.0)
c    +  ic = ichmv(ias,ic,2H- ,1,1)
     +  ic = ichmv_ch(ias,ic,'-')
C  Put in minus sign first if necessary
      ndig = 0
C  We have no digits processed yet 
      idec = 0
C  There are no characters after the . yet 
C 
C 
C     2. Main loop over max number of characters desired. 
C     Do not fill in leading zeros. 
C 
      i=1 
C  The digit counter for exponentiation
200   idigit = val/10.0d0**(nci-i) - valint   
C200   IDIGIT = VAL*10.0**(I-NCI) - VALINT  
      if(idigit.lt.0) idigit=val/10.0d0**(nci-1)-valint+.5
C     IF(IDIGIT.LT.0.OR.IDIGIT.GT.9) IDIGIT=VAL*10.**(I-NCI)-VALINT 
      if (idigit.lt.0.or.idigit.gt.9) goto 300
C                   Get the Ith digit in the number 
      if (idigit.ne.0.or.ndig.gt.0.or.nci.eq.i) goto 202
C  Go to put in this digit if
C  1) the digit is non-zero
C  2) this is an embedded zero 
C  3) this is the zero before the decimal point
      if (nchtot.lt.0) ic = ichmv(ias,ic,llead,1,1) 
C  Move in leading spaces or zeros for RIGHT-justify 
      goto 210
202   continue
      if(ndig.eq.0.and.value.lt.0.0.and.ncfrac.ge.0)
c    +  ic =  ichmv(ias,ic,2H- ,1,1)  
     +  ic =  ichmv_ch(ias,ic,'-')  
      ic = ic + ib2as(idigit,ias,ic,1)
C  Convert this digit.  We should get back a $ if
C  the digit is too large. 
      ndig = 1
C  Set the flag, we've started adding digits 
      if (idec.gt.0) idec=idec+1
C  Increment count of digits past decimal point
      if (nci.ne.i) goto 201
c     ic = ichmv(ias,ic,2H. ,1,1) 
      ic = ichmv_ch(ias,ic,'.') 
      idec = 1
C  If we're at the 10**0 point, add "."
201   valint = (valint+idigit)*10.0d0 
210   i = i + 1 
      if (ic.lt.ifc+nch.and.idec-1.lt.ncfr) goto 200
C 
      ir2as = ic-ifc
      return
C 
C 
C     3. Clearly, the number will not fit into the field we 
C     were given.  Fill it up with $$$$$ and finish.
C 
300   call ifill_ch(ias,ifc,nch,'$')
      ir2as = nch 
C
! AEM 20050112 commented return
!      return
      end 
