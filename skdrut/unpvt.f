      SUBROUTINE unpvt(IBUF,ILEN,IERR,LIDTER,LNATER,bitden,
     .maxtap,nrec,lb,sefd,pcount,par,npar)
C
C     UNPVT unpacks a record containing Mark III terminal information.
C
      include '../skdrincl/skparm.ftni'
C
C  History
C  891116 nrv Added sefd
C  891117 nrv Removed sefd - save this for a later day
C  900116 nrv Added tape length, sefd, bands
C  900119 nrv Removed lb, sefd to decoding on LO lines
C  900206 nrv Replace lb, sefd, make compatible with old schedule files
C             Changed IDTER to integer
C  900301 nrv Allow IDTER to be integer or hollerith
C  920520 nrv Add SEFD parameters
C  911022 nrv add nrec parameter
C  930225 nrv implicit none
C 951116 nrv Change max_pas to bit density
C 960227 nrv Change IDTER to LIDTER, up to 4 characters
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer containing the record
C     ILEN  - length of IBUF in words
      integer pcount ! number of arguments, 5 for ID and name only
C
C  OUTPUT:
      integer maxtap,ierr,nrec
      integer*2 lidter(2)
C     LIDTER - terminal ID
      real bitden
C     IERR    - error return, 0=ok, -100-n=error in nth field
      integer*2 LNATER(4) ! name of the terminal
C     maxtap - maximum tape length for this station
      integer*2 lb(*)  ! bands
      real*4 sefd(*),par(max_sefdpar,*)
      integer npar(*)   ! sefds
C
C  Local:
      real*8 R,DAS2B
      integer ich,nch,ic1,ic2,idumy,i,nc,ib1,ib2,ib
      integer ichmv_ch,ichcm,ichmv,ias2b,ichcm_ch ! function
C
C     Start the unpacking with the first character of the buffer.
C
      ICH = 1
C
C     1. The terminal ID. 
C
      idumy = ichmv_ch(lidter,1,'    ')
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
C     id=ias2b(ibuf,ic1,nch)
      if (nch.gt.4) then
        ierr=-101
        return
      endif
      idumy = ichmv(lidter,1,ibuf,ic1,nch)
C
C     2. Terminal name, 8 characters.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN  !
        IERR = -102
        RETURN
      END IF  !
      CALL IFILL(LNATER,1,8,oblank)
      IDUMY = ICHMV(LNATER,1,IBUF,IC1,NCH)
C
      if (pcount.le.5) return
C
C  3. Maximum number of 28-track passes.  If not present, set to default.
C
C     CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
C     NCH = IC2-IC1+1
C     IF  (IC1.EQ.0) THEN
C       MAXPAS = MAX_PASS
C     ELSE
C       MAXPAS = IAS2B(IBUF,IC1,NCH)
C     ENDIF
C     IF  (MAXPAS.EQ.-32768) THEN  !
C       IERR = -103
C       RETURN
C     END IF  !

C  3. Bit density that is normal for this station.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      nc=ic2-ic1+1
      if (ic1.eq.0) then
        bitden=0
      else
        R = DAS2B(IBUF,IC1,NC,IERR)
        IF (IERR.EQ.0) THEN
          bitden = R
        else
          ierr=-104
          return
        endif
      endif

C  4. Maximum tape length. If not present, set to default.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      IF  (IC1.eq.0) THEN
        maxtap = MAX_TAPE
        nrec = 1
      else
        nrec = 1
        if (ichcm_ch(ibuf,ic1,'2x').eq.0) then !dual
          nrec = 2
          ic1 = ic1+2
        endif
        NCH = IC2-IC1+1
        MAXTAP = IAS2B(IBUF,IC1,NCH)
      ENDIF
      IF  (MAXTAP.EQ.-32768) THEN  !
        IERR = -104
        RETURN
      END IF  !
C
C   Two bands, two SEFDs, two sets of parameters.
C   Format: X sefd S sefd X pow t0 t1 .. S pow t0 t1 .. 
C   Up to MAX_SEFDPAR parameters will be read following the
C   band designator. If none present, set all to zero.
C
      do i=1,2 ! X sefd S sefd 
C       Band designator.
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        call ifill(lb(i),1,2,oblank)
        if (ic1.ne.0) then 
          NCH = IC2-IC1+1
          IF  (NCH.NE.1) THEN  !
            IERR = -105
            RETURN
          END IF  !
          IDUMY = ICHMV(LB(i),1,IBUF,IC1,NCH)
        endif
C
C       SEFD.  If not present, set to zero. 
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        sefd(i)=0.0
        if (ic1.ne.0) then
          NC = IC2-IC1+1
          R = DAS2B(IBUF,IC1,NC,IERR)
          IF (IERR.EQ.0) THEN
            sefd(i) = R
          else
            ierr=-106
          endif
        endif
      enddo
C
      npar(1)=0
      npar(2)=0
C  X pow t0 t1 ... S pow t0 t1 ...
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      if (ic1.ne.0) then ! got some parameters
        if (ic2-ic1+1.ne.1) then
          ierr=-107
          return
        endif
        if (ichcm(ibuf,ic1,lb(1),1,1).eq.0) then
          ib1=1
          ib2=2
        else
          ib2=1
          ib1=2
        endif
        ib=ib1
        i=0
        do while (ic1.ne.0)
          CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
          if (ic1.eq.0) return
          if (ichcm(ibuf,ic1,lb(ib2),1,1).eq.0) then !start of second set 
            i=0
            ib = ib2
            CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
          endif
          r = das2b(ibuf,ic1,ic2-ic1+1,ierr)
          i=i+1
          if (ierr.ne.0) then
            ierr=-108-npar(ib1)-npar(ib2) 
          else
            par(i,ib)=r
            npar(ib)=npar(ib)+1
          endif
        enddo
      endif

C
      RETURN
      END
