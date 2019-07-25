C@IR2AS
      integer FUNCTION IR2AS(VALUE,IAS,IFC,NCHTOT,
     .     NCFRAC)
C
C     This function converts a real number to ASCII format
C
      implicit none
C  INPUT:
C     VALUE - real value to be converted
      real*4 value
      integer*2 IAS(*)
      integer ifc,nchtot,ncfrac
C      - string array for ASCII value
C     IFC - first character to use in IAS
C     NCHTOT - maximum number of characters in field
C  >0 for left-justify, <0 for right-justify
C     NCFRAC - number of characters in fraction, i.e. following
C  decimal point.  >0 for leading spaces, <0 leading zeros
C     **NOTE: NCHTOT and NCFRAC are similar in function to the two
C     digits n and m used in the FORTRAN format Fn.m, respectively.
C
C  OUTPUT:
C     IR2AS - number of characters used in formatting value
C
C  LOCAL:
      INTEGER*2 LLEAD !   added by P. Ryan
      real*8 VAL
C     VAL - absolute value of VALUE
      real*8 VALINT
C     VALINT - integer part, as number is being built up
C     IDIGIT - current digit being added to number
C     NDIG - set to 1 once leading zeros are passed over
C     IC - current character in output string
C     IDEC - number of characters following decimal point
C     NCI - number of characters requested for integer part
C     IX - number of spaces pre-empted by "-" or "."
      integer ix,nci,idec,ic,ndig,idigit,nch,ncfr,i
      integer ichmv,ib2as ! functions
C
C
C     1. First initialize the counters and indices.
C
      NCH = IABS(NCHTOT)
C       The total number of characters we can use
      NCFR = IABS(NCFRAC)
C       The number of characters in the fractional part
      call char2hol('  ',llead,1,2)
C     LLEAD = 2H
      IF (NCFRAC.LT.0) call char2hol('00',llead,1,2)
C       Establish the character for leading blanks or zeros
      VAL = ABS(VALUE)+0.5*0.1**NCFR
C       The value to be converted
      VALINT = 0.0D0
C       The integer part of the number so far
      IX = 1
C       We expect to exclude one space for a decimal point
      IF (VALUE.LT.0.0) IX = 2
C       We might have a sign to include,
C       so need to pre-empt another space
C     IF (NCFR.EQ.0) IX=IX-1
C       Maybe no decimal point is wanted at all
C     We can't handle the no-decimal point case easily, so skip it
      NCI = NCH-NCFR-IX
C       So, the number of characters in the INTEGER
C       part of the number is the total less the number
C       in the fraction and the number for . and/or -
      IF (NCI.EQ.0) GOTO 300
C       If we won't have any room for the integer
C       part of the number, go fill with $$
      IC = IFC
C       Start character counter where requested
      IF (VALUE.LT.0.0.AND.NCFRAC.LT.0)
     +  IC = ichmv_ch(IAS,IC,'-')
C       Put in minus sign first if necessary
      NDIG = 0
C       We have no digits processed yet
      IDEC = 0
C       There are no characters after the . yet
C
C
C     2. Main loop over max number of characters desired.
C     Do not fill in leading zeros.
C
      I=1
C       The digit counter for exponentiation
200   IDIGIT = VAL/10.0D0**(NCI-I) - VALINT
C200   IDIGIT = VAL*10.0**(I-NCI) - VALINT
      IF(IDIGIT.LT.0) IDIGIT=VAL/10.0D0**(NCI-1)-VALINT+.5
C     IF(IDIGIT.LT.0.OR.IDIGIT.GT.9) IDIGIT=VAL*10.**(I-NCI)-VALINT
      IF (IDIGIT.LT.0.OR.IDIGIT.GT.9) GOTO 300
C       Get the Ith digit in the number
      IF (IDIGIT.NE.0.OR.NDIG.GT.0.OR.NCI.EQ.I) GOTO 202
C       Go to put in this digit if
C       1) the digit is non-zero
C       2) this is an embedded zero
C       3) this is the zero before the decimal point
      IF (NCHTOT.LT.0) IC = ICHMV(IAS,IC,LLEAD,1,1)
C       Move in leading spaces or zeros for RIGHT-justify
      GOTO 210
202   CONTINUE
      IF(NDIG.EQ.0.AND.VALUE.LT.0.0.AND.NCFRAC.GE.0)
     +  IC =  ichmv_ch(IAS,IC,'-')
      IC = IC + IB2AS(IDIGIT,IAS,IC,1)
C       Convert this digit.  We should get back a $ if
C       the digit is too large.
      NDIG = 1
C       Set the flag, we've started adding digits
      IF (IDEC.GT.0) IDEC=IDEC+1
C       Increment count of digits past decimal point
      IF (NCI.NE.I) GOTO 201
      IC = ichmv_ch(IAS,IC,'.')
      IDEC = 1
C       If we're at the 10**0 point, add "."
201   VALINT = (VALINT+IDIGIT)*10.0D0
210   I = I + 1
      IF (IC.LT.IFC+NCH.AND.IDEC-1.LT.NCFR) GOTO 200
C
      IR2AS = IC-IFC
      RETURN
C
C
C     3. Clearly, the number will not fit into the field we
C     were given.  Fill it up with $$$$$ and finish.
C
300   CALL IFILL(IAS,IFC,NCH,2H$$)
      IR2AS = NCH
      RETURN
C
      END
