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
      double precision sp,ohfac,fanfac
      integer ichcm_ch
C
C
      if (is.le.0.or.is.gt.nstatn.or.
     .    icode.le.0.or.icode.gt.ncodes) then ! illegal
        speed=-1.0
        return
      endif

C 1. First account for the fan factor.

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
      sp=sp/12.0 ! convert to fps
C
      speed=sp
      RETURN
      END
