C@GTPRM
      SUBROUTINE GTPRM(IBUF,IFC,IEC,ITYPE,PARM,IERR,PCOUNT)
C
C        GTPRM parses the input buffer and returns the next parameter
C
      implicit none
C     INPUT VARIABLES:
      integer*2 ibuf(*)
      integer ifc,iec,itype
C        IFC,IEC- first, last characters to scan in buffer
C        ITYPE  - type of parameter expected:
C     0 - ASCII
C     1 - integer
C     2 - real
      INTEGER PCOUNT
C     replacement for obsolete intrinsic function call.  -P. Ryan
C
C     OUTPUT VARIABLES:
      real*4 parm
C        PARM   - parameter value found.
C     If ASCII - up to 4 characters returned
C     If integer - value is first word of PARM
C     If real - value is PARM
C     If current value - * is returned
C     If default - , is returned
      integer ierr
C        IERR   - error return from ASCII to binary conversion
C
C     CALLED SUBROUTINES: Lee's character routines: ISCNC,ICHMV,IAS2B,RAS2B
C
C  LOCAL VARIABLES
      real*8 DAS2B
C        NCH    - number of characters up to the comma
C        ICOM   - character index of comma
C        VALUE  - decoded value, set to PARM on exit
      real*4 value
      integer IVAL(2),nargs,ierx,nch,icom
C   - integer equivalent of VALUE
      integer oblank,idum
      integer ichmv,iscnc,jchar,ias2b ! functions
      EQUIVALENCE (VALUE,IVAL(1))
      data oblank /O'40'/
C
C     PROGRAMMER: nrv
C     LAST MODIFIED: 810422
C     930225 nrv implicit none
C
C
C     1. First scan for a comma and get the number of characters to decode.
C     If the first character IFC is beyond the last character IEC, there
C     are no characters so indicate default value.
C
      NARGS = PCOUNT
      IERX = 0
C
      PARM = 0.0
      IF (IFC.LE.IEC) GOTO 100
      NCH = 0
      ICOM = IFC-1
      GOTO 210
100   ICOM = ISCNC(IBUF,IFC,IEC,o'54')
C       Scan for a comma
      IF (ICOM.EQ.0) ICOM = IEC+1
C       If no comma found, indicate beyond last character
      NCH = ICOM - IFC
      IF (ITYPE.EQ.0) NCH = MIN0(NCH,4)
C       For ASCII values, take at most 4 characters only
C
C
C     2. Decide if default value was desired (i.e. no specification in
C     this field).  Also decide if current value was wanted (i.e. * was
C     specified instead of value).
C
C     Routines to handle Holleriths wer added by by P. Ryan.  Obsolete
C     syntax is commented out.
C
      IF (NCH.GT.0) GOTO 250
210   call char2hol(', ',ival(1),1,2)
C     IVAL(1) = 2H,
      GOTO 900
C
250   IF (NCH.GT.1.OR.JCHAR(IBUF,IFC).NE.o'53') GOTO 300
      call char2hol('* ',ival(1),1,2)
C     IVAL(1) = 2H*
      GOTO 900
C
C
C     3. For ASCII data, move characters into IVAL.
C     For integer, decode into IVAL.
C     For real, decode into VALUE.
C
300   IF (ITYPE.NE.0) GOTO 310
      CALL IFILL(IVAL,1,4,oblank)
      idum= ICHMV(IVAL,1,IBUF,IFC,NCH)
C       Move characters into output
      GOTO 900
C
C   Subscripts to IVAL addedby P. Ryan

310   IF (ITYPE.NE.1) GOTO 320
      IVAL(1) = IAS2B(IBUF,IFC,NCH)
      IF (IVAL(1).EQ.-32768) IERX = -1
      GOTO 900
C
320   IF (ITYPE.NE.2) GOTO 990
      VALUE = DAS2B(IBUF,IFC,NCH,IERX)
C
900   PARM = VALUE
      IFC = ICOM+1
      IF (NARGS.GT.5) IERR = IERX
990   RETURN
      END
