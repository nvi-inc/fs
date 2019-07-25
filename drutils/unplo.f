      SUBROUTINE unplo(IBUF,ILEN,IERR,
     .LIDSTN,LCODE,LSUBGR,IFCHAN,LIFINP,FREQLO)
C
C     UNPLO unpacks the record holding information on a LO configuration
C
      include 'skparm.ftni'

C  History:
C  900126 NRV Changed last parameter so no error is generated
C             for older format SKED files.
C  910709 NRV Allow LO3
C  930225 nrv implicit none
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr,ifchan
      integer*2 lidstn,lcode,lsubgr,lifinp
      real*4 freqlo
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C     LIDSTN - 1-char station ID
C     LCODE - frequency code, 2 char
C     LSUBGR - sub-group within the freq code, 1 char in upper byte
C     IFCHAN - IF distributor channel, value 1 or 2
C     LIFINP - IF distributor input, N or A, in upper byte
C     FREQLO - sum of LO frequencies, MHz
C
C  LOCAL:
      real*8 DAS2B
      real*4 d
      integer ich,nch,ic1,ic2,i,l,idumy
      integer jchar,ichmv,ias2b
C
C
C     1. Start decoding this record with the first character.
C
      IERR = 0
      ICH = 1
C
C
C     Station code, 1 character
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.1) THEN  !
        IERR = -101
        RETURN
      END IF  !
      call char2hol ('  ',LIDSTN,1,2)
      IDUMY = ICHMV(LIDSTN,1,IBUF,IC1,NCH)
C
C     Frequency code, 2 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.2) THEN  !
        IERR = -102
        RETURN
      END IF  !
      call char2hol ('  ',LCODE,1,2)
      IDUMY = ICHMV(LCODE,1,IBUF,IC1,NCH)
C
C     Sub-group, 1 character
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.1) THEN  !
        IERR = -103
        RETURN
      END IF  !
      call char2hol ('  ',LSUBGR,1,2)
      IDUMY = ICHMV(LSUBGR,1,IBUF,IC1,NCH)
C
C     IF distributor channel and input
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      I = IAS2B(IBUF,IC1+2,1)
      L = JCHAR(IBUF,IC1+3)
      IF  ((I.NE.1.AND.I.NE.2.and.i.ne.3).OR.
     .(L.NE.OCAPA.AND.L.NE.OCAPN)) THEN
        IERR = -104
        RETURN
        END IF  !
      IFCHAN = I
      call char2hol ('  ',LIFINP,1,2)
      IDUMY = ICHMV(LIFINP,1,L,2,1)
C
C     RF frequency
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (IERR.LT.0) THEN  !
        IERR = -105
        RETURN
      END IF  !
      FREQLO = D
C
      RETURN
      END
