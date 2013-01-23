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
          NCH = IC2-IC1+1
          R = DAS2B(IBUF,IC1,NCH,IERR)
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
