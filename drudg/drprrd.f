      subroutine drprrd(ivexnum)

C   DRPRRD reads the lines in the $PARAM section needed by drudg.
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C History
C 020713 nrv copied from sked

C Input
      integer ivexnum

C Local
      integer nch,ilen,ic1,ic2,ich,ncout,idummy,ierr
      character*128 cout
      integer*2 ibufq(100)
      logical kmore
      integer ichmv,ichcm_ch,i2long,trimlen,jchar
      integer fget_literal,iret,ptr_ch,fget_all_lowl,fvex_len

      if (.not.kvex) then ! find $PARAM section
        rewind(lu_infile)
        ibufq(1) = 0
        DO WHILE (ibufq(1).ne.-1.and.ichcm_ch(ibuf,1,'$PARAM').NE.0) 
          call ifill(ibuf,1,isklen*2,oblank)
          CALL READS(lu_infile,ierr,IBUF,isklen,ilen,2) ! get next line
          ibufq(1) = ilen
        enddo
      else ! find SCHEDULING_PARAMS literal
        iret=fget_all_lowl(ptr_ch(char(0)),ptr_ch(char(0)),
     .  ptr_ch('literals'//char(0)),
     .  ptr_ch('SCHEDULING_PARAMS'//char(0)),ivexnum)
        if (iret.lt.0) return
        kgeo = .true.
      endif ! $PARAM or SCHEDULING_PARAMS

C  Get the initial line of parameters
      call ifill(ibuf,1,isklen*2,oblank)
      if (.not.kvex) then ! read sk file first line
        CALL READS(lu_infile,ierr,IBUF,isklen,ilen,2)
        ibufq(1) = ilen
      else ! get first literal line
        iret=fget_literal(ibuf) ! first fget is null
        iret=fget_literal(ibuf)
        ibufq(1) = iret
      endif ! sk/vex
      kmore = .true.

C  Loop on parameter section lines
      DO WHILE (kmore) !decode an entry
        ICH=1
        CALL GTFLD(IBUF,ICH,i2long(IBUFQ(1)),IC1,IC2)
        nch=ibufq(1)-ic2
        IF  (ichcm_ch(IBUF,IC1,'SUBNET ').EQ.0) THEN  !SUB line
        ELSE IF (ichcm_ch(IBUF,IC1,'SCAN ').EQ.0) THEN !SCAN line
        ELSE IF (ichcm_ch(IBUF,IC1,'WEIGHT ').EQ.0) THEN 
        ELSE IF (ICHCM_ch(IBUF,IC1,'TAPE_TYPE ').EQ.0) THEN 
          ibufq(1) = nch
          idummy=ichmv(ibufq(2),1,ibuf,ic2+1,nch)
          CALL TTAPE(IBUFQ,luscn,luscn)
        ELSE IF (ICHCM_ch(IBUF,IC1,'TAPE_MOTION ').EQ.0) THEN 
          ibufq(1) = nch
          idummy=ichmv(ibufq(2),1,ibuf,ic2+1,nch)
          CALL STAPE(IBUFQ,luscn,luscn)
        ELSE IF (ICHCM_ch(IBUF,IC1,'TAPE_ALLOCATION ').EQ.0) THEN 
          ibufq(1) = nch
          idummy=ichmv(ibufq(2),1,ibuf,ic2+1,nch)
          CALL ATAPE(IBUFQ,luscn,luscn)
        ELSE IF (ICHCM_ch(IBUF,IC1,'ELEVATION ').EQ.0) THEN 
          ibufq(1) = nch
          idummy=ichmv(ibufq(2),1,ibuf,ic2+1,nch)
          CALL SELEV(IBUFQ,luscn,luscn)
        ELSE IF (ICHCM_ch(IBUF,IC1,'EARLY_START ').EQ.0) THEN 
          ibufq(1) = nch
          idummy=ichmv(ibufq(2),1,ibuf,ic2+1,nch)
          CALL SEARL(IBUFQ,luscn,luscn)
        ELSE IF (ichcm_ch(IBUF,IC1,'SNR ').EQ.0) THEN !SNR
        ELSE IF (ichcm_ch(IBUF,IC1,'SNR_1 ').EQ.0) THEN !SNR_1
        ELSE
          idummy=ichmv(ibufq(2),1,ibuf,1,i2long(ibufq(1)))
          CALL drSET(IBUFQ)
        ENDIF
        call ifill(ibuf,1,isklen*2,oblank)
        if (.not.kvex) then ! read sk file first line
          CALL READS(lu_infile,ierr,IBUF,isklen,ilen,2)
          ibufq(1) = ilen
          kmore = JCHAR(IBUF,1).NE.ODOLLAR.AND.IBUFQ(1).NE.-1
        else ! get first literal line
          iret=fget_literal(ibuf)
          ibufq(1) = iret
          kmore = iret.gt.0
        endif ! sk/vex
      enddo

      return
      end
