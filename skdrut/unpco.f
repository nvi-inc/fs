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
C 951019 nrv change "14" to max_chan, "28" to max_pass, observing mode
C            may be 8 characters

C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr,ivcn
      integer*2 lcode,lsubgr,lmode(4)
      real*4 freqrf,freqpc,vcband
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C     LCODE - frequency code, 2-char
C     LSUBGR - subgroup within the code, 1-char in upper byte
C     FREQRF - observing frequency, MHz
C     FREQPC - phase cal frequency, Hz
C     IVCN - video converter for this frequency
C     LMODE - observing mode, 1 char in upper byte
C     VCBAND - final video bandwidth, MHz
      integer ITRK(4,max_pass)
C      - tracks to be recorded, by pass
C
C  LOCAL:
      integer IPARM(2),j,idumy,i,ipas
      real*4 parm,d
      EQUIVALENCE (IPARM(1),PARM)
      real*8 DAS2B
C     ITx - count of tracks found in the last fields
C     IPAS - pass number found in the last fields
C     ix - count of p(t1,t2,t3,t4) fields found
      integer ich,nch,ic2,ic1,ict,ip,ix,itx,it1
      integer ichmv,ias2b,iscnc ! functions
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
      IF  (I.LT.1.OR.I.GT.max_chan) THEN  !
        IERR = -105
        RETURN
      END IF  !
      IVCN = I
C
C
C     Observing mode
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN  !
        IERR = -106
        RETURN
      END IF  !
      call ifill(lmode,1,8,oblank)
      IDUMY = ICHMV(LMODE,1,ibuf,ic1,nch)
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
C     Sub-Pass and tracks to be recorded. May be up to 4 tracks
C     in format p(t1,t2,t3,t4). Not all tracks need be specified.
C     t1 is for USB, t2 for LSB for sign bit.
C     t3 is for USB, t4 for LSB for magnitude bit. <<<<<< This is how
C                                                         2-bit sampling
C                                                         is specified.
C
      DO  I=1,max_pass ! initialize
        do j=1,4
          ITRK(j,I) = -99
        enddo
      END DO  !initialize
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IX = 1
      DO WHILE (IC1.NE.0) !get p(t1,t2,t3,t4) fields
        IP=ISCNC(IBUF,IC1,IC2,OLPAREN)
C                              (
C            Find the opening parenthesis
        IF  (IP.EQ.0) THEN  !no tracks!
          IERR = -107-IX
          RETURN
        END IF  !no tracks!
        IPAS = IAS2B(IBUF,IC1,IP-IC1) ! the tape sub-pass
        IF  (IPAS.lt.0) THEN  
          IERR = -107-IX
          RETURN
        END IF  !
        ICT=IP+1  ! Start the scan after the opening parenthesis
        IC2=IC2-1 ! Only scan up to the closing parenthesis
        itx=0
        do while (ict.le.ic2) ! scan (t1,t2,t3,t4)
          CALL GTPRM(IBUF,ICT,IC2,1,PARM,NULL,5)
          it1=iparm(1)
          if (it1.lt.-3.or.it1.gt.36) then 
            ierr=-107-ix
            return
          endif
          itx=itx+1
          ITRK(itx,IPAS) = it1
          IX = IX + 1
        enddo ! scan (t1,t2,t3,t4)
        IF  (itx.eq.0) THEN  !no tracks in this field!
          IERR = -107-IX
          RETURN
        END IF  !no tracks!
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      END DO  !get p(t1,t2) fields
C
C
      RETURN
      END
