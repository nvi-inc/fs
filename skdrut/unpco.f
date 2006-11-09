      SUBROUTINE unpco(IBUF,ILEN,IERR,
     .LCODE,LSUBGR,FREQRF,FREQPC,Ichan,LMODE,VCBAND,itrk_map,cswit,ivc)
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
! 2006Nov09 JMG. Changed logical for checking valid bandwidths

C  INPUT:
      integer*2 IBUF(*)
      character*256 cbuf
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
      integer*4 itrk_map(max_headstack,max_trk) ! tracks to be recorded

      character*3 cswit ! switching
      integer ivc ! physical BBC# for this channel

! function
      integer*4 itras_ind
      integer iwhere_in_real8_list
      integer ichmv,ias2b,iscnc ! functions
C
C  LOCAL:
      integer ic2save,idumy,i,ipas
      double precision d
      integer icnt
      integer*4 ind
      double precision DAS2B
C     ITx - count of tracks found in the last fields
C     IPAS - pass number found in the last fields
C     ix - count of p(t1,t2,t3,t4) fields found
      integer ihead,ich,nch,ic2,ic1,ict,ip,ix,itx
      integer ibit,isb
      integer num_bw
      parameter (num_bw=13)
      double precision bw_valid(num_bw)
      data bw_valid/14.67, 18.0,
     >0.125,0.25,0.5,1.0,2.0,4.0,8.0,16.0,32.0,64.0,128.0/

C
C
C     1. Start decoding this record with the first character.
C        Assumes that first character is not a C.
C        i.e. send IBUF(2) if first character is a C.

      call hol2char(ibuf,1,ilen*2,cbuf)

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

      if(ierr .lt. 0) then
         ierr=-107
         return
      endif
      i=iwhere_in_real8_list(bw_valid,num_bw,d)
      if(i .eq. 0) then
        write(*,*) "UNPCO: Invalid Bandwidth: ", d
        ierr=-107
        return
      endif
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
! parse the expression. Can be up to 4
! first count the number of commas.
        icnt=0
        do while(icnt .lt. 4 .and. ict .le. ic2)
          ind=index(cbuf(ict:ic2),",")
          if(ind .eq. 0) ind=ic2-ict+1
          icnt=icnt+1
          ix=ix+1
          if(cbuf(ict:ict) .ne. ",") then
            read(cbuf(ict:ict+ind-1),*,err=900) itx
            itx=itx+3
            if(itx.lt. 1  .or. itx .gt. max_trk) then
               write(*,*) "UNPCO: Invalid track assignment"
               ierr=-107-ix
               return
            endif
            if (ihead.le.max_headstack)  then
               ibit=(icnt-1)/2
               isb=icnt-2*ibit
               ibit=ibit+1
               itrk_map(ihead,itx)=itras_ind(isb,ibit,ichan,ipas)
            endif
          endif
          ict=ict+ind
        end do
        IF  (icnt.eq.0) THEN  !no tracks in this field!
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
      cswit = '   '
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
        cswit = '   '
        cswit=cbuf(ic1:ic2)
        IF ((cswit(1:1).ne.'1').and.(cswit(1:1).ne.'2').and.
     .      (cswit(1:1).ne.'0').and.(cswit.ne.'1,2')) then
          IERR = -109-ix
          RETURN
        END IF  !
      endif
      return

! error return
900   continue

      RETURN
      END
