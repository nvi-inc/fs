      SUBROUTINE unpfr(IBUF,ILEN,IERR,
     .LFR,LC,llo,lb,nb,lmode,lhd,lvcbw,
     .lfpc,lfvc,pcount)
C
C     UNPFR unpacks the lines in the SEQUENCE.CAT catalog
C     Note that most of the fields are left as hollerith variables
C     so that the SKED format lines can be easily assembled.
C
      include 'skparm.ftni'

C  History:
C  900117 NRV Created, modeled after UNPFR of old FRCAT program
C  930225 nrv implicit none
C  950522 nrv Remove check for specific letters for valid modes.
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C      - buffer having the record
C     ILEN - length of the record in IBUF, in words.
C
C  OUTPUT
      integer ierr
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
      integer*2 LFR(4)      ! name of frequency record
      integer*2 LC          ! frequency code - 2 characters
      integer*2 llo(4)      ! name of LO group in LO.CAT
      integer*2 lb(2)       ! frequency bands
      integer nb(2)       ! number of VCs in each band
      integer*2 lmode       ! frequency mode - 1 character
      integer*2 lhd(4)      ! name of head group in HEAD.CAT
      integer*2 lvcbw(4)    ! VC bandwidth
      integer*2 lfpc(4)     ! phase cal frequency
      integer*2 lfvc(4,14)  ! RF frequencies for each VC
      integer pcount      ! number of arguments
C
C  LOCAL:
      real*8 DAS2B
      integer nargs,nc,ic1,ic2,nch,ich,ib,iv,l,n,idumy
      integer ichmv,jchar,ias2b
C
C
      NARGS = PCOUNT
      IERR = 0
      ICH=1
C
C     Name - 8 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN 
        IERR = -101
        RETURN
      END IF
      CALL IFILL(LFR,1,8,oblank)
      IDUMY = ICHMV(LFR,1,IBUF,IC1,NCH)
C
C     Frequency code, 2 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.2) THEN
        IERR = -102
        RETURN
      END IF 
      call char2hol ('  ',LC,1,2)
      IDUMY = ICHMV(LC,1,IBUF,IC1,NCH)
C
      IF (NARGS.LT.6) RETURN
C
C     LO group name, 8 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN 
        IERR = -103
        RETURN
      END IF
      CALL IFILL(LLO,1,8,oblank)
      IDUMY = ICHMV(LLO,1,IBUF,IC1,NCH)
C
C     Frequency band, number of freqs in this band
C
      do ib=1,2
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        NCH = IC2-IC1+1
        IF  (NCH.GT.2.OR.NCH.LT.0) THEN
          IERR = -104+ib-1
          RETURN
        END IF
        CALL IFILL(lb(ib),1,2,oblank)
        IDUMY = ICHMV(lb(ib),1,IBUF,IC1,NCH)
C
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        N = IAS2B(IBUF,IC1,IC2-IC1+1)
        IF  (N.GT.14.OR.N.LT.0) THEN
          IERR = -105+ib-1
          RETURN
        END IF
        nb(ib) = n
      enddo
C
C     Observing mode, 1 character
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      L = JCHAR(IBUF,IC1)
C     IF  ((NCH.GT.1).OR.(L.LT.OCAPA.OR.L.GT.OCAPE)) THEN
C       IERR = -108
C       RETURN
C     END IF
      call char2hol('  ',LMODE,1,2)
      IDUMY = ICHMV(LMODE,1,L,2,1)
C
C     Head group name, max 8 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN 
        IERR = -109
        RETURN
      END IF
      CALL IFILL(LHD,1,8,oblank)
      IDUMY = ICHMV(LHD,1,IBUF,IC1,NCH)
C
C     Video bandwidth
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
C     D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
C     IF  (IERR.LT.0.OR.(D.NE.4.0.AND.D.NE.2.0.AND.D.NE.1.0.AND.
C    .     D.NE.0.5.AND.D.NE.0.25.AND.D.NE.0.125)) THEN
C       IERR = -110
C       RETURN
C     END IF
C     VCBW = D
      CALL IFILL(LVCBW,1,8,oblank)
      IDUMY = ICHMV(LVCBW,1,IBUF,IC1,NCH)
C
C     Phase cal frequency
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
C     D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
C     IF  (IERR.LT.0.) THEN
C       IERR = -111
C       RETURN
C     END IF
C     fpc = D
      CALL IFILL(LFPC,1,8,oblank)
      IDUMY = ICHMV(LFPC,1,IBUF,IC1,NCH)
C
C     VC frequencies, max 14 of them
C
      do iv=1,14
        call ifill(lfvc(1,iv),1,8,oblank)
      enddo
      do iv=1,nb(1)+nb(2)
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        NCH = IC2-IC1+1
C       D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
C       IF  (IERR.LT.0.) THEN
C         IERR = -111+iv
C         RETURN
C       END IF
C       fvc(iv) = d
        IDUMY = ICHMV(LFVC(1,iv),1,IBUF,IC1,NCH)
      enddo
C
      RETURN
      END
