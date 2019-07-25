      SUBROUTINE unpco(IBUF,ILEN,IERR,
     .LCODE,LSUBGR,FREQRF,FREQPC,IVCN,LMODE,VCBAND,
     .ITRK)
C
C     UNPCO unpacks the record holding information on a frequency code
C     element.
C
      include 'skparm.ftni'
C  History:
C  950622 nrv Remove check for valid letters for mode.
C             Check for tracks between -3 and 36.

C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr,ivcn
      integer*2 lcode,lsubgr,lmode
      real*4 freqrf,freqpc,vcband
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C     LCODE - frequency code, 2-char
C     LSUBGR - subgroup within the code, 1-char in upper byte
C     FREQRF - observing frequency, MHz
C     FREQPC - phase cal frequency, Hz
C     IVCN - video converter for this frequency
C     LMODE - observing mode, 1 char in upper byte
C     VCBAND - final video bandwidth, MHz
      integer ITRK(2,28)
C      - tracks to be recorded, by pass
C
C  LOCAL:
      integer IPARM(2),idumy,i,l,ipas
      real*4 parm,d
      EQUIVALENCE (IPARM(1),PARM)
      real*8 DAS2B
C     IT1, IT2 - tracks found in the last fields
C     IPAS - pass number found in the last fields
      integer ich,nch,ic2,ic1,ict,ip,ix,it1,it2
      integer ichmv,jchar,ias2b,iscnc ! functions
C
C
C     1. Start decoding this record with the first character.
C        Assumes that first character is not a C.
C        i.e. send IBUF(2) if first character is a C.

C
      IERR = 0
      ICH = 1
C
C
C     Frequency code, 2 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.2)  THEN  !
        IERR = -101
        RETURN
      END IF  !
      call char2hol ('  ',LCODE,1,2)
      IDUMY = ICHMV(LCODE,1,IBUF,IC1,NCH)
C
C
C     Sub-group, 1 character
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.1)  THEN  !
        IERR = -102
        RETURN
      END IF  !
      call char2hol ('  ',LSUBGR,1,2)
      IDUMY = ICHMV(LSUBGR,1,IBUF,IC1,NCH)
C
C
C     RF frequency
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (IERR.LT.0) THEN  !
        IERR = -103
        RETURN
      END IF  !
      FREQRF = D
C
C
C     Phase cal frequency
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (IERR.LT.0) THEN  !
        IERR = -104
        RETURN
      END IF  !
      FREQPC = D
C
C
C     Video converter number
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      I = IAS2B(IBUF,IC1,IC2-IC1+1)
      IF  (I.LT.1.OR.I.GT.14) THEN  !
        IERR = -105
        RETURN
      END IF  !
      IVCN = I
C
C
C     Observing mode, 1 character
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      idumy = ichmv(l,1,ibuf,ic1,1)
C     L = JCHAR(IBUF,IC1)
C     IF  ((NCH.GT.1).OR.(L.LT.OCAPA.OR.L.GT.OCAPE)) THEN  !
C       IERR = -106
C       RETURN
C     END IF  !
      call char2hol ('  ',LMODE,1,2)
      IDUMY = ICHMV(LMODE,1,L,1,1)
C
C
C     Final video bandwidth
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (IERR.LT.0.OR.(D.NE.4.0.AND.D.NE.2.0.AND.D.NE.1.0.AND.D.NE.0.5
     .     .AND.D.NE.0.25.AND.D.NE.0.125.and.d.ne.18.0.and.d.ne.8.0
     .     .and.d.ne.16.0
     .     .and.d.ne.14.67))  THEN  !
        IERR = -107
        RETURN
      END IF  !
      VCBAND = D
C
C
C     Pass and tracks to be recorded
C
      DO  I=1,28 ! "initialize"
        ITRK(1,I) = -99
        ITRK(2,I) = -99
      END DO  !"initialize"
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IX = 1
      DO WHILE (IC1.NE.0) !"get p(t1,t2) fields"
        IP=ISCNC(IBUF,IC1,IC2,OLPAREN)
C                              (
C            Find the opening parenthesis
        IF  (IP.EQ.0) THEN  !"no tracks!"
          IERR = -107-IX
          RETURN
        END IF  !"no tracks!"
        IPAS = IAS2B(IBUF,IC1,IP-IC1)
C                   The tape pass
        IF  (IPAS.lt.0) THEN  !
          IERR = -107-IX
          RETURN
        END IF  !
        ICT=IP+1
C                   Start the scan after the opening parenthesis
        IC2=IC2-1
C                   Only scan up to the closing parenthesis
        CALL GTPRM(IBUF,ICT,IC2,1,PARM,NULL,5)
        IF  (JCHAR(IPARM,1).EQ.OCOMMA) THEN  !"no tracks!"
          IERR = -107-IX
          RETURN
        END IF  !"no tracks!"
        IT1 = IPARM(1)
        ITRK(1,IPAS) = IT1
        IT2 = 0
        CALL GTPRM(IBUF,ICT,IC2,1,PARM,NULL,5)
        IF (JCHAR(IPARM,1).NE.OCOMMA) then ! second track
          IT2=IPARM(1)
          ITRK(2,IPAS) = IT2
        endif ! second track
C       if (it1.lt.0.or.it1.gt.28.or.it2.lt.0.or.it2.gt.28) then
        if (it1.lt.-3.or.it1.gt.36.or.it2.lt.-3.or.it2.gt.36) then
          ierr=-107-ix
          return
        endif
C
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        IX = IX + 1
      END DO  !"get p(t1,t2) fields"
C
C
      RETURN
      END
