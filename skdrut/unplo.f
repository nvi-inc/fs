      SUBROUTINE unplo(IBUF,ILEN,IERR,
     .LIDSTN,LCODE,LSUBGR,LIFINP,FREQLO,
     .iv,cs)
C
C     UNPLO unpacks the record holding information on a LO configuration
C
      include 'skparm.ftni'

C  History:
C  900126 NRV Changed last parameter so no error is generated
C             for older format SKED files.
C  910709 NRV Allow LO3
C  930225 nrv implicit none
C 951019 nrv Extend line to include index number and other info
C 951020 nrv If info is missing, send back blanks or zeros, not error.
C            This will make it backward compatible.
C 951116 nrv Remove "ib" from call
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr,iv,is
      integer*2 lidstn,lcode,lsubgr,lifinp,ls
      real*4 freqlo
      character*3 cs
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C     LIDSTN - 1-char station ID
C     LCODE - frequency code, 2 char
C     LSUBGR - sub-group within the freq code, 1 char in upper byte
C     LIFINP - IF distributor input, 1 or 2 or 3, N or A, or A,B,C,D
C     FREQLO - sum of LO frequencies, MHz
C
C  LOCAL:
      real*8 DAS2B
      real*4 d
      integer ich,nch,ic1,ic2,i,l,idumy
      integer ichcm_ch,jchar,ichmv,ias2b
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
C     May be: IFA,IFB,IFC,IFD or IF1N,IF2N,IF1A,IF2A,IF3A
C         of A,B,C,D
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      if (ichcm_ch(ibuf,ic1,'IF').eq.0) then 
        I = IAS2B(IBUF,IC1+2,1)
        if (i.gt.0) then ! valid Mark III channel
          L = JCHAR(IBUF,IC1+3)
          IF  ((I.NE.1.AND.I.NE.2.and.i.ne.3).OR.
     .    (L.NE.OCAPA.AND.L.NE.OCAPN)) THEN
            IERR = -104
            RETURN
          END IF  !
          IDUMY = ICHMV(LIFINP,1,ibuf,ic1+2,2)
        else ! maybe a VLBA channel
          l = jchar(ibuf,ic1+2)
          if (l.ne.ocapa.and.l.ne.ocapb.and.
     .        l.ne.ocapc.and.l.ne.ocapd) then
            ierr=-104
            return
          endif
          IDUMY = ICHMV(LIFINP,1,ibuf,ic1+2,2)
        endif
      else ! VLBA 1-letter channel
        l = jchar(ibuf,ic1+2)
        if (l.ne.ocapa.and.l.ne.ocapb.and.
     .      l.ne.ocapc.and.l.ne.ocapd) then
          ierr=-104
          return
        endif
        IDUMY = ICHMV(LIFINP,1,ibuf,ic1,2)
      endif
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
C From here on, older schedules may not have the info.
C Schedules from PC-SCHED may have patching here.
C
C Initialize for missing information:
      iv=0
      call char2hol ('  ',LS,1,2)
      cs = '   '

C     VC# or BBC# to be recorded
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      if (ic1.eq.0) return
      NCH = IC2-IC1+1
      iv = ias2b(ibuf,ic1,nch)
      if (iv.lt.0) then ! illegal, assume PC-SCHED line
        iv=0
        return
      endif
      IF  ((iv.lt.1.or.iv.gt.max_chan)) THEN  !
        IERR = -106
        RETURN
      END IF  !
C
C     SB - Side Band for this BBC, either U or L
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      if (ic1.eq.0) return
      NCH = ic2-ic1+1
      if ((jchar(ibuf,ic1).ne.OCAPU.and.jchar(ibuf,ic1).ne.OCAPL)
     ..or.nch.ne.1) then
        IERR = -106
        RETURN
        END IF  !
      call char2hol ('  ',LS,1,2)
      IDUMY = ICHMV(LS,1,ibuf,ic1,1)
C
C     Set number - 0 1 2 or 1,2
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      if (ic1.eq.0) return
      NCH = IC2-IC1+1
      cs = '   '
      call hol2char(ibuf,ic1,ic2,cs)
      IF ((cs(1:1).ne.'1').and.(cs(1:1).ne.'2').and.
     .    (cs(1:1).ne.'0').and.(cs.ne.'1,2')) then
        IERR = -107
        RETURN
      END IF  !
C
      RETURN
      END
