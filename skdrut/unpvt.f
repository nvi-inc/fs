      SUBROUTINE unpvt(IBUF,ILEN,IERR,LIDTER,LNATER,ibitden,
     .nstack,mxtap,nrec,ls2sp,
     .lb,sefd,pcount,par,npar,lrack,lreca,lrecb)
C
C     UNPVT unpacks a record containing Mark III terminal information.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
C
C  Called by: stinp
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
C 960409 nrv Add headstack, ibitden
C 980625 nrv Allow maxtape to be "auto" instead of a value and set
C            maxtap=-1 as the flag for this configuration
C 990607 nrv Add rack and recorder types. Also formatter type for K4.
C 990620 nrv Read S2 mode following rec type, store in LFM
C 991103 nrv Use common arrays to check rack/rec names. Remove formatter.
C            Add recb. Change maxtap to mxtap
C 991122 nrv Decode fields for S2 and K4 recorders.
C 000319 nrv Index for checking equipment match was off by one.
C 000531 nrv Remove 'auto' option for tape length.
C 001017 nrv Allow single-band SEFDs followed by equipment. ** DON't
C            implement this until a FS upgrade can be done.
C 011011 nrv If the second recorder field doesn't match a recorder type
C            and the first recorder is S2, then the second field is mode.
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer containing the record
C     ILEN  - length of IBUF in words
      integer pcount ! number of arguments, 5 for ID and name only
C
C  OUTPUT:
      integer mxtap,ierr,nrec
      integer*2 lidter(2)
C     LIDTER - terminal ID
      integer nstack ! number of headstacks
      integer ibitden
C     IERR    - error return, 0=ok, -100-n=error in nth field
      integer*2 LNATER(4) ! name of the terminal
C     mxtap - maximum tape length for this station
      integer*2 lb(*)  ! bands
      real*4 sefd(*),par(max_sefdpar,*)
      integer npar(*)   ! sefds
      integer*2 lrack(4),lreca(4),lrecb(8),ls2sp(2)
C
C  Local:
      real*8 R,DAS2B
      integer ich,nch,ic1,ic2,idum,i,ib1,ib2,il
      integer trimlen,ichmv_ch,ichcm,ichmv,ias2b,ichcm_ch ! function
      logical kmatch,ks2,kk4
C
C     Initialize
C
      ierr=0
      npar(1)=0
      npar(2)=0
      nstack=0
      nrec=0
      ibitden=0
      mxtap=0
      ICH = 1
C
C     1. The terminal ID. 
C
      idum = ichmv_ch(lidter,1,'    ')
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
C     id=ias2b(ibuf,ic1,nch)
      if (nch.gt.4) then
        ierr=-101
        return
      endif
      idum = ichmv(lidter,1,ibuf,ic1,nch)
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
      idum = ICHMV(LNATER,1,IBUF,IC1,NCH)
      ks2=.false.
      kk4=.false.
      if (ichcm_ch(lnater,1,'S2').eq.0) ks2=.true.
      if (ichcm_ch(lnater,1,'K4').eq.0) kk4=.true.
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

C  3. Number of headstacks at this station.
C     Bit density capability at this station.
C     Format:  <heads>x<bitden> where heads is required,
C     and ibitden is optional.
C
C     Decode the next two fields depending on the type of terminal.
C                         *******  *****
C  Mk3/4  T 102  KO-VLBA  1x56000  2x17640   X   900   S   750
C  S2     T 102  KO-VLBA   SLP     2x360     X   900   S   750
C  K4     T 102  KO-VLBA   1       2x240     X   900   S   750
C                         *******  *****
C K4 recorder parameters
      if (kk4) then ! reserved, nominal length of tape
C first field reserved
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        if (ic1.eq.0) return
        nch=ic2-ic1+1
        i = IAS2B(IBUF,IC1,nch) ! reserved
        if (i.lt.0) then
          ierr=-104
          return
        endif
C second field number of recorders and tape length
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        nrec = 1
        if (ichcm_ch(ibuf,ic1,'2x').eq.0) then !dual recs
          nrec = 2
          ic1 = ic1+2
        endif
C       if (ichcm_ch(ibuf,ic1,'auto').eq.0.or.
C    .      ichcm_ch(ibuf,ic1,'AUTO').eq.0) then ! auto alloc
C         mxtap = -1
C       else
          NCH = IC2-IC1+1
          mxtap = IAS2B(IBUF,IC1,NCH)
C       endif
        IF  (mxtap.le.0.and.mxtap.ne.-1) THEN  !
          IERR = -105
          RETURN
        END IF  
C S2 recorder
      else if (ks2) then ! speed, nominal length of tape
C first field tape speed, either LP or SLP
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        if (ic1.eq.0) return
        nch=ic2-ic1+1
        if (nch.gt.8.or.ichcm_ch(ibuf,ic1,'LP').ne.0.and.
     .    ichcm_ch(ibuf,ic1,'SLP').ne.0) then
          ierr=-104
          return
        endif
        idum = ichmv(ls2sp,1,ibuf,ic1,nch)
C field 2 number of recorders and length of tape
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        nrec = 1
        if (ichcm_ch(ibuf,ic1,'2x').eq.0) then !dual recs
          nrec = 2
          ic1 = ic1+2
        endif
        if (ichcm_ch(ibuf,ic1,'auto').eq.0.or.
     .      ichcm_ch(ibuf,ic1,'AUTO').eq.0) then ! auto alloc
          mxtap = -1
        else
          NCH = IC2-IC1+1
          mxtap = IAS2B(IBUF,IC1,NCH)
        endif
        IF  (mxtap.le.0.and.mxtap.ne.-1) THEN  !
          IERR = -104
          RETURN
        END IF  !
C Mk34/VLBA tapes
      else ! Mk34/VLBA headstacksxdensity, nominal length of tape
C first field headstacks and density
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        if (ic1.eq.0) return
        i = IAS2B(IBUF,IC1,1) ! number of headstacks
        if (i.lt.0) then
          ierr=-104
          return
        endif
        nstack = i
        if (ichcm_ch(ibuf,ic1+1,'x').eq.0) then ! bit density follows
          ic1 = ic1+2
          NCH = IC2-IC1+1
          i = IAS2B(IBUF,IC1,NCH)
          if (i.gt.0) then
            ibitden = i
          else
            ierr=-104
            return
          endif
        endif ! bit density follows
C second field number of recorders and tape length
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        nrec=1
        IF  (IC1.eq.0) THEN
          mxtap = MAX_TAPE
          nrec = 1
          return
        endif
        if (ichcm_ch(ibuf,ic1,'2x').eq.0) then !dual recs
          nrec = 2
          ic1 = ic1+2
        endif
        if (ichcm_ch(ibuf,ic1,'auto').eq.0.or.
     .      ichcm_ch(ibuf,ic1,'AUTO').eq.0) then ! auto alloc
          mxtap = -1
          nrec = 2
        else
          NCH = IC2-IC1+1
          mxtap = IAS2B(IBUF,IC1,NCH)
        endif
        IF  (mxtap.le.0.and.mxtap.ne.-1) THEN  !
          IERR = -105
          RETURN
        END IF  
      endif ! K4/S2/Mk34
C
C   Two bands, two SEFDs, two sets of parameters.
C   Format: X sefd S sefd X pow t0 t1 .. S pow t0 t1 .. 
C   Up to MAX_SEFDPAR parameters will be read following the
C   band designator. If none present, set all to zero.
C   If the first band is neither X nor S don't get a second one.
C
      do i=1,2 ! X sefd S sefd 
        call ifill(lb(i),1,2,oblank)
        sefd(i)=0.0
C********** Wait to implement this when all of FS is updated ********
C       if (i.eq.1.or.
C    .   (i.eq.2.and.(ichcm_ch(lb(1),1,'X').eq.0.or.
C    .    ichcm_ch(lb(1),1,'S').eq.0))) then ! get second of X or S band
C         Band designator.
C********************************************************************
          CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
          if (ic1.ne.0) then 
            NCH = IC2-IC1+1
            IF  (NCH.NE.1) THEN  !
              IERR = -105
              RETURN
            END IF  !
            idum = ICHMV(LB(i),1,IBUF,IC1,NCH)
          endif
C
C         SEFD.  If not present, set to zero. 
          CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
          if (ic1.ne.0) then
            NCH = IC2-IC1+1
            R = DAS2B(IBUF,IC1,NCH,IERR)
            IF (IERR.EQ.0) THEN
              sefd(i) = R
            else
              ierr=-106
            endif
          endif
C**********************************88
C       endif
C**********************************88
      enddo
C
C  X pow t0 t1 ... S pow t0 t1 ...
C  The SEFD model might be missing, in which case go to the rack/rec part.
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) ! first band
      nch=ic2-ic1+1
      if (ic1.ne.0.and.nch.eq.1) then ! got some SEFD parameters
        if (ichcm(ibuf,ic1,lb(1),1,1).eq.0) then
          ib1=1
          ib2=2
        else
          ib2=1
          ib1=2
        endif
        i=0
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) ! first parameter
        do while (ic1.ne.0.and.ichcm(ibuf,ic1,lb(ib2),1,1).ne.0) ! first set 
          if (ic1.eq.0) return
          r = das2b(ibuf,ic1,ic2-ic1+1,ierr)
          i=i+1
          if (ierr.ne.0) then
            ierr=-108-npar(ib1)-npar(ib2) 
          else
            par(i,ib1)=r
            npar(ib1)=npar(ib1)+1
          endif
          CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) ! next parameter
        enddo ! first band
        do i=1,npar(ib1) ! same number parameters X and S
          CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) ! first parameter of second set
          if (ic1.eq.0) return
          r = das2b(ibuf,ic1,ic2-ic1+1,ierr)
          if (ierr.ne.0) then
            ierr=-108-npar(ib1)-npar(ib2) 
          else
            par(i,ib2)=r
            npar(ib2)=npar(ib2)+1
          endif
        enddo ! second band
      endif ! got some SEFD parameters
C
C Rack, Rec types
      idum = ichmv_ch(lrack,1,'        ')
      idum = ichmv_ch(lreca,1,'        ')
      idum = ichmv_ch(lrecb,1,'        ')
C     GTFLD has already been done above if there were no SEFD parameters.
      if (npar(1).gt.0) CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
C Rack field
      if (ic1.ne.0) then ! rack field
        nch = min0(ic2-ic1+1,8)
        idum = ichmv(lrack,1,ibuf,ic1,nch)
C       Convert these cases to lower case
        if (ichcm_ch(lrack,1,'MARK3A').eq.0) 
     .     idum = ichmv_ch(lrack,1,'Mark3A')
        if (ichcm_ch(lrack,1,'MARK4').eq.0) 
     .     idum = ichmv_ch(lrack,1,'Mark4')
        i=1
        kmatch=.false.
        do while (i.le.max_rack_type.and..not.kmatch) ! check rack type
          il=trimlen(crack_type(i))
          kmatch = ichcm_ch(lrack,1,crack_type(i)(1:il)).eq.0
          i=i+1
        enddo ! check rack type
        if (i.gt.max_rack_type+1) ierr=-10-2*npar(1)
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
C Rec A field
        if (ic1.ne.0) then ! rec A field
          nch = min0(ic2-ic1+1,8)
          idum = ichmv(lreca,1,ibuf,ic1,ic2-ic1+1)
          if (ichcm_ch(lreca,1,'MARK3A').eq.0) 
     .     idum = ichmv_ch(lreca,1,'Mark3A')
          if (ichcm_ch(lreca,1,'MARK4').eq.0) 
     .     idum = ichmv_ch(lreca,1,'Mark4')
          i=1
          kmatch=.false.
          do while (i.le.max_rec_type.and..not.kmatch) ! check rec A type
            il=trimlen(crec_type(i))
            kmatch = ichcm_ch(lreca,1,crec_type(i)(1:il)).eq.0
            i=i+1
          enddo ! check rec A type
          if (i.gt.max_rec_type+1) ierr=-11-2*npar(1)
          CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2) 
C Rec B field or S2 mode
          if (ic1.ne.0) then ! rec B or S2 mode field
            nch = min0(ic2-ic1+1,8)
            idum = ichmv(lrecb,1,ibuf,ic1,ic2-ic1+1)
            if (ichcm_ch(lrecb,1,'MARK3A').eq.0) 
     .       idum = ichmv_ch(lrecb,1,'Mark3A')
            if (ichcm_ch(lrecb,1,'MARK4').eq.0) 
     .       idum = ichmv_ch(lrecb,1,'Mark4')
C           check recorder 
            i=1
            kmatch=.false.
            do while (i.le.max_rec_type.and..not.kmatch) ! check rec B type
              il=trimlen(crec_type(i))
              kmatch = ichcm_ch(lrecb,1,crec_type(i)(1:il)).eq.0
              i=i+1
            enddo ! check rec B type
            if (ichcm_ch(lreca,1,'S2').eq.0) then ! field is S2 mode
            else ! field is rec
              if (i.gt.max_rec_type+1) ierr=-12-2*npar(1)
              nrec = 2
            endif ! S2 mode/error
          endif ! rec B or S2 mode field
        endif ! rec A field
      endif ! rack field
C
      RETURN
      END
