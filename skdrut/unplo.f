      SUBROUTINE unplo(IBUF,ILEN,IERR,
     .LIDSTN,LCODE,LSUBGR,LIFINP,FREQLO,
     .iv,ls,nv)
C
C     UNPLO unpacks the record holding information on a LO configuration
C
      include '../skdrincl/skparm.ftni'

C  History:
C  900126 NRV Changed last parameter so no error is generated
C             for older format SKED files.
C  910709 NRV Allow LO3
C  930225 nrv implicit none
C 951019 nrv Extend line to include index number and other info
C 951020 nrv If info is missing, send back blanks or zeros, not error.
C            This will make it backward compatible.
C 951116 nrv Remove "ib" from call
C 960124 nrv Missing SB argument in call.
C 960121 nrv Remove switching and channel from call.
C 960228 nrv Change iv to an array, add nv as count. Decode patching
C            from PC-SCHED lines and use as BBC/VC assignments
C 970117 nrv Allow IF3O and IF3I (out and in). If "N" is encountered,
C            assume it's I, i.e. "in".
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr,iv(max_chan),nv
      integer*2 lidstn,lcode,lsubgr,lifinp,ls
      real*4 freqlo
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
      integer ivv,ich,nch,ic1,ic2,i,l,idumy
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
C     May be: IFA,IFB,IFC,IFD or IF1N,IF2N,IF1A,IF2A,IF3O,IF3I
C         or A,B,C,D or 1N,2N,1A,2A,3O,3I
C         Interpret 3N as 3I 
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      i=ias2b(ibuf,ic1,1) ! decode first character
      if (ichcm_ch(ibuf,ic1,'IF').eq.0) then ! IFnx
        I = IAS2B(IBUF,IC1+2,1)
        if (i.gt.0) then ! valid Mark III channel: 1, 2, or 3
          L = JCHAR(IBUF,IC1+3)
          IF  ((I.NE.1.AND.I.NE.2.and.i.ne.3).OR.
     .    (L.NE.OCAPA.AND.L.NE.OCAPN.and.
     .     l.ne.ocapo.and.l.ne.ocapi)) THEN ! suffix A,N,O,I
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
      else if (i.ge.1.and.i.le.3) then ! 1,2,3
        l=jchar(ibuf,ic1+1)
        IF  ((I.NE.1.AND.I.NE.2.and.i.ne.3).OR.
     .  (L.NE.OCAPA.AND.L.NE.OCAPN.and.l.ne.ocapi.and.l.ne.ocapo)) THEN
          IERR = -104
          RETURN
        END IF  !
        IDUMY = ICHMV(LIFINP,1,ibuf,ic1,2)
      else ! VLBA 1-letter channel
        l = jchar(ibuf,ic1)
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
C Schedules from PC-SCHED may have patching here, pick up and
C use as physical BBC/VC assignments.

C Initialize for missing information:
      do i=1,max_chan
        iv(i)=0
      enddo
      nv=0
      call char2hol ('  ',LS,1,2)

C     VC# or BBC# assigned to this channel

      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      if (ic1.eq.0) return
      NCH = IC2-IC1+1
      ivv = ias2b(ibuf,ic1,nch)
      IF  ((ivv.lt.1.or.ivv.gt.max_chan)) THEN  ! check for patching
        if (jchar(ibuf,ic2).eq.ocaph.or.jchar(ibuf,ic2).eq.ocapl) then
C              trailing "L" or "H" means patching
          nv=0
          do while (ic1.gt.0) ! get patching fields
            ivv = ias2b(ibuf,ic1,nch-1)
            if (ivv.lt.1.or.ivv.gt.max_chan) then ! error
              ierr=-106-nv
              return
            endif
            nv=nv+1
            iv(nv)=ivv
            call gtfld(ibuf,ich,ilen*2,ic1,ic2)
            nch=ic2-ic1+1
          enddo
          return ! no more on the line 
        else
          IERR = -106
          RETURN
        endif
      else
        nv=1
        iv(nv)=ivv
      END IF  !
C
C     SB - Side Band for this BBC, either U or L
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      if (ic1.eq.0) return
      NCH = ic2-ic1+1
      if ((jchar(ibuf,ic1).ne.OCAPU.and.jchar(ibuf,ic1).ne.OCAPL)
     ..or.nch.ne.1) then
        IERR = -107
        RETURN
        END IF  !
      call char2hol ('  ',LS,1,2)
      IDUMY = ICHMV(LS,1,ibuf,ic1,1)
C
      RETURN
      END
