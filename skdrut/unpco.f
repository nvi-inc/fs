      SUBROUTINE unpco(IBUF,ILEN,IERR,
     .LCODE,LSUBGR,FREQRF,FREQPC,Ichan,LMODE,VCBAND,
     .ITRK,cs,ivc)
C
C     UNPCO unpacks the record holding information on a frequency code
C     element.
C
      include '../skdrincl/skparm.ftni'
C  History:
C  950622 nrv Remove check for valid letters for mode.
C             Check for tracks between -3 and 36.
C 951019 nrv change "14" to max_chan, "28" to max_pass, observing mode
C            may be 8 characters
C 960126 nrv Decode sub-passes allowing null track assignments.
C            This leaves room for the magnitude bit assignment.
C 960121 nrv Add switching and BBC# to call, decode at end of line.
C 960405 nrv Move ISCNC to after check for IC1=0 in decoding tracks
C 960408 nrv Check IC2 before doing the next ISCNC.
C 960409 nrv Allow high-number passes for headstack 2
C 970206 nrv Remove itr2 and add headstack index
C 970206 nrv Change max_pass to max_subpass
C 991122 nrv Change LMODE to allow 16 characters.

C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr,ichan
      integer*2 lcode,lsubgr,lmode(8)
      real freqpc,vcband
      double precision freqrf
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C     LCODE - frequency code, 2-char
C     LSUBGR - subgroup within the code, 1-char in upper byte
C     FREQRF - observing frequency, MHz
C     FREQPC - phase cal frequency, Hz
C     Ichan - channel number for this frequency
C     LMODE - observing mode, max 16 characters
C     VCBAND - final video bandwidth, MHz
      integer ITRK(4,max_subpass,max_headstack) ! tracks to be recorded
      character*3 cs ! switching
      integer ivc ! physical BBC# for this channel
C
C  LOCAL:
      integer ic2save,IPARM(2),j,idumy,i,ipas
      real parm
      double precision d
      EQUIVALENCE (IPARM(1),PARM)
      double precision DAS2B
C     ITx - count of tracks found in the last fields
C     IPAS - pass number found in the last fields
C     ix - count of p(t1,t2,t3,t4) fields found
      integer k,ihead,ich,nch,ic2,ic1,ict,ip,ix,itx,it1
      integer jchar,ichmv,ias2b,iscnc ! functions
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
C     Channel number
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      I = IAS2B(IBUF,IC1,IC2-IC1+1)
      IF  (I.LT.1.OR.I.GT.max_chan) THEN  !
        IERR = -105
        RETURN
      END IF  !
      Ichan = I
C
C
C     Observing mode
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.16) THEN  !
        IERR = -106
        RETURN
      END IF  !
      call ifill(lmode,1,16,oblank)
      IDUMY = ICHMV(LMODE,1,ibuf,ic1,nch)
C
C
C     Final video bandwidth
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      D = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
      IF  (IERR.LT.0.OR.(D.NE.4.0.AND.D.NE.2.0.AND.D.NE.1.0.AND.D.NE.0.5
     .     .AND.D.NE.0.25.AND.D.NE.0.125.and.d.ne.18.0.and.d.ne.8.0
     .     .and.d.ne.16.0.and.d.ne.32.0
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
      DO  I=1,max_subpass ! initialize
        do j=1,4 ! sb and bits
          do k=1,max_headstack
            ITRK(j,I,k) = -99
          enddo
        enddo
      END DO  !initialize
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) ! get first character
      IX = 1
      if (ic1.eq.0) then ! no tracks !
        ierr=-107-ix
        return
      endif
      IC2=ISCNC(IBUF,IC1,ilen*2,ORPAREN) ! find closing paren
      IP=ISCNC(IBUF,IC1,IC2,OLPAREN)
C                              (        Find the opening parenthesis
      DO WHILE (ip.gt.0) !get p(t1,t2,t3,t4) fields
        IPAS = IAS2B(IBUF,IC1,IP-IC1) ! the tape sub-pass
        ihead=1
        if (ipas.gt.100) then ! headstack 2
          ipas=ipas-100
          ihead=2
        endif
        IF  (IPAS.lt.0.or.ipas.gt.max_subpass) THEN  
          IERR = -107-IX
          RETURN
        END IF  !
        ICT=IP+1  ! Start the scan after the opening parenthesis
        IC2=IC2-1 ! Only scan up to the closing parenthesis
        itx=0
        do while (ict.le.ic2) ! scan (t1,t2,t3,t4)
          CALL GTPRM(IBUF,ICT,IC2,1,PARM,NULL,5)
          IX = IX + 1
          itx=itx+1
          if (itx.gt.4) then ! too many
            ierr=-107-ix
            return
          endif
          if (jchar(iparm,1).ne.OCOMMA) then ! value
            it1=iparm(1)
            if (it1.lt.-3.or.it1.gt.36) then 
              ierr=-107-ix
              return
            endif
            if (ihead.le.max_headstack) ITRK(itx,IPAS,ihead) = it1
          endif ! value
        enddo ! scan (t1,t2,t3,t4)
        IF  (itx.eq.0) THEN  !no tracks in this field!
          IERR = -107-IX
          RETURN
        END IF  !no tracks!
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) ! may be BBC#
        ic2save=ic2 ! so save ic2
        ip=0
        if (ic1.gt.0) then
          IC2=ISCNC(IBUF,IC1,ilen*2,ORPAREN) ! find closing paren
          if (ic2.gt.0) then ! closing paren found
            IP=ISCNC(IBUF,IC1,IC2,OLPAREN)
          else
            ip=0 ! not a track
          endif
        endif
      END DO  !get p(t1,t2,t3,t4) fields
C
C  Done with track assignments. Now check for switching and BBC #s.
C
      ivc=0
      cs = '   '
      if (ic1.eq.0) return ! nothing there

C  Physical BBC#. 
C  Use ic1 and ic2save from previous gtfld
C
      ic2=ic2save
      I = IAS2B(IBUF,IC1,IC2-IC1+1)
      IF  (I.LT.1.OR.I.GT.max_chan) THEN  !
        IERR = -108-ix
        RETURN
      END IF  !
      ivc = I

C     switching set number - 0 1 2 or 1,2
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      if (ic1.gt.0) then
        NCH = IC2-IC1+1
        cs = '   '
        call hol2char(ibuf,ic1,ic2,cs)
        IF ((cs(1:1).ne.'1').and.(cs(1:1).ne.'2').and.
     .      (cs(1:1).ne.'0').and.(cs.ne.'1,2')) then
          IERR = -109-ix
          RETURN
        END IF  !
      endif


      RETURN
      END
