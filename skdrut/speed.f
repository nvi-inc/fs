      real FUNCTION SPEED(ICODE,is)

C   SPEED returns the actual tape speed in feet per second
C   Restrictions: 
C    - Channel bandwidth for BBC 1 is used.
C    - VLBA/MkIII mode factor is 9.072/9.0
C
C History
C 951213 nrv Modified to use bit density and other factors.
C 960126 nrv Modified to use mode to determine if VLBA type
C 960304 nrv Return -1 if icode=0.
C 960319 nrv Use sample rate not bandwidth. Change calculation to
C            use correct factor for DR or NDR.
C 960531 nrv Fanout factor already in common.
C 961031 nrv Check LMFMT for the recording format instead of LMODE
C            because LMODE is used for a mode name in the non-VEX file.
C            In the non-VEX file, LMFMT will be modified by user input
C            to DRUDG to be either "M" or "V".
C 990524 nrv Use tape_dens instead of bitdens. tape_dens is set by scheduler.
C 990524     NOTE: Use density for only code 1. Normally can't change 
C 990524     recording density during an experiment anyway.
C 990621 nrv Use bitdens because this is read from the schedule file.
C            If user changes it then bitdens gets changed.
C 000126 nrv Add S2 speed output.
C 000319 nrv Add K4 speed calculation.
C 010817 nrv Change K4 speeds per Takashima.
C 020111 nrv Check LSTREC not LTERNA for recorder type.
C 020713 nrv Add third K4 speed for 128 Mbps.
C 020926 nrv Change K4 sample rate logic to get correct speed (per S. Kurihara)
C 021003 nrv Calculate K4 speed in dm/s not m/s. This will make the
C            footages in the schedule be in dm not meters, for more precision.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
C
C  INPUT:
      integer icode ! code index in common
      integer is ! station index
C
C  OUTPUT:
C     SPEED - tape speed, fps
C
C  LOCAL:
      double precision sp,ohfac,fanfac,totrate
      integer ichcm_ch
      logical ks2,kk4
C
C
      if (is.le.0.or.is.gt.nstatn.or.
     .    icode.le.0.or.icode.gt.ncodes) then ! illegal
        speed=-1.0
        return
      endif

C Determine type of equipment.

C     ks2 = ichcm_ch(lterna(1,is),1,'S2').eq.0
C     kk4 = ichcm_ch(lterna(1,is),1,'K4').eq.0
      ks2 = ichcm_ch(lstrec(1,is),1,'S2').eq.0
      kk4 = ichcm_ch(lstrec(1,is),1,'K4').eq.0

      if (ks2) then
        if (ichcm_ch(ls2speed(1,is),1,'LP').eq.0) then
          sp = speed_lp ! ips
        else if (ichcm_ch(ls2speed(1,is),1,'SLP').eq.0) then
          sp = speed_slp ! ips
        else ! unknown
          speed=-1.0
          return
        endif
        sp=sp/12.0 ! convert to fps

      else if (kk4) then 
        totrate=samprate(icode)*(ntrkn(1,is,icode)+ntrkn(2,is,icode))
        if (totrate.gt.129.0) then
          sp = 423.8 ! mm/sec for 256 Mbps
        else if (totrate.lt.65.0) then
          sp = 105.9 ! mm/sec for 64 Mbps
        else 
          sp = 211.9 ! mm/sec for 128 Mbps
        endif
        sp=sp/100.0 ! convert to dm/s

C 1. First account for the fan factor.

      else ! Mk3/4
        if (ifan(is,icode).gt.0) then
          fanfac=1/real(ifan(is,icode))
        else
          fanfac=1.0
        endif

C 2. Get the correct overhead factor for DR or NDR.

        ohfac = 1.125    ! factor is 8/9 for Mk3/4 DR format
        if (ichcm_ch(lmfmt(1,is,icode),1,'V').eq.0) then
          ohfac = 1.134  ! factor is 9.072/8 for VLBA NDR format
        endif

C 3. Calculate the tape speed. Sample rate is in Mb/s.

        SP = ohfac * fanfac * samprate(icode)*1.d6
     .              / bitdens(is,icode) ! ips
C
      sp=sp/12.0 ! convert to fps

      endif ! S2/K4/Mk3/4

      speed=sp

      RETURN
      END
