      SUBROUTINE VUNPDAS(stdef,ivexnum,iret,ierr,lu,
     .lidter,lnater,nstack,maxtaplen,nrec,lb,sefd,par,npar,
     .lrec,lrack,ctapemo,ite,itl,itg,ls2sp,ns2tap,ltlc)
C
C     VUNPDAS gets the recording terminal information for station
C     STDEF and converts it. Returns on error from any vex routine.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
C
C  History:
C 960517 nrv New.
C 960521 nrv Revised.
C 960810 nrv Add tape motion fields
C 960817 nrv Add S2 tape length and tape motion fields
C 961022 nrv Change MARK to Mark if found in rack and recorder names.
C 970114 nrv Add "_type" to rack and recorder Vex names.
C 970123 nrv Move initialization to start.
C 970406 nrv Make ctapemo always upper case
C 971006 nrv Add "VLBA4" rec and rack types.
C 990611 nrv Add rack and rec types for K4.
C 990921 nrv Add ltlc "two_letter_code". Added statn and skobs includes.
C 991108 nrv Remove hard-coded rack and recorder names and use the
C            list initialized in skdrini.
C 000907 nrv Get second headstack statement. If there are two of
C            them, set NSTACK=2.
C 020110 nrv Check S2 tape speed, must be LP or SLP. Make upper case.
C
C  INPUT:
      character*128 stdef ! station def to get
      integer ivexnum ! vex file ref
      integer lu ! unit for writing error messages
C
C  OUTPUT:
      integer iret ! non-zero error return from vex routines
      integer ierr ! error return from this routine, >0 tells which
C                    section had vex error, <0 is invalid value
      integer maxtaplen,nrec
      integer*2 lidter(2) ! terminal ID
      integer nstack ! number of headstacks
      integer*2 LNATER(4) ! name of the terminal
      integer*2 lb(*)  ! bands
      real sefd(*),par(max_sefdpar,*)
      integer npar(*)   ! sefds
      integer*2 lrec(4),lrack(4) ! recorder and rack types
      character*128 ctapemo ! tape motion type
      integer ite,itl,itg ! early, late, gap 
      integer*2 ls2sp(2) ! S2 tape speed
      integer ns2tap ! number of S2 tapes
      integer*2 ltlc ! two_letter_code, if none use LIDTER
C
C  LOCAL:
      character*128 cout,cunit,ctemp
      double precision d
      integer i,nch,idumy
      logical ks2 ! true for an S2 recorder
      integer fvex_double,fvex_int,fget_station_lowl,fvex_field,
     .fvex_units,
     .ptr_ch,fvex_len,ichcm_ch,ichmv_ch ! function
C
C
C  Initialize in case we have to leave early.

      CALL IFILL(lrec,1,8,oblank)
      CALL IFILL(lrack,1,8,oblank)
      idumy = ichmv_ch(lidter,1,'    ')
      idumy = ichmv_ch(ltlc,1,'    ')
      CALL IFILL(lnater,1,8,oblank)
      nstack=1 ! default
      maxtaplen = MAX_TAPE
      CALL IFILL(ls2sp,1,8,oblank)
      ns2tap=0
      nrec = 1 ! default
      ite=0
      itl=0
      itg=0 
      ctapemo=''
      ks2=.false.

C  1. The recorder type
C
      ierr=1
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('record_transport_type'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get recorder name
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        IF  (NCH.GT.8.or.NCH.le.0) THEN  !
          write(lu,'("VUNPDAS01 - Recorder type name too long: ",a)') 
     .    cout(1:nch)
          ierr=-1
        else
          IDUMY = ICHMV_ch(lrec,1,cout(1:nch))
          if (ichcm_ch(lrec,1,'MARK3A').eq.0) 
     .    IDUMY = ICHMV_ch(lrec,1,'Mark3A')
          if (ichcm_ch(lrec,1,'MARK4').eq.0) 
     .    IDUMY = ICHMV_ch(lrec,1,'Mark4')
          i=1
          do while (i.le.max_rec_type.and.cout(1:nch).ne.crec_type(i))
            i=i+1
          enddo
          if (i.gt.max_rec_type) then ! no match
            write(lu,'("VUNPDAS22 - Unrecognized recorder type: ",a)')
     .      cout(1:nch)
          endif ! no match
          ks2 = cout(1:2).eq.'S2'
        endif
      endif

C  2. The rack type
C
      ierr = 2
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('electronics_rack_type'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get rack name
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        IF  (NCH.GT.8.or.NCH.le.0) THEN  !
          write(lu,'("VUNPDAS02 - Rack type name too long: ",a)') 
     .    cout(1:nch)
          ierr=-2
        else
          IDUMY = ICHMV_ch(lrack,1,cout(1:nch))
          if (ichcm_ch(lrack,1,'MARK3A').eq.0)
     .    IDUMY = ICHMV_ch(lrack,1,'Mark3A')
          if (ichcm_ch(lrack,1,'MARK4').eq.0)
     .    IDUMY = ICHMV_ch(lrack,1,'Mark4')
          i=1
          do while (i.le.max_rack_type.and.cout(1:nch).ne.crack_type(i))
            i=i+1
          enddo
          if (i.gt.max_rack_type) then ! no match
            write(lu,'("VUNPDAS22 - Unrecognized rack type: ",a)')
     .      cout(1:nch)
          endif ! no match
        endif
      endif
C
C  3. The terminal ID. 
C
      ierr = 3
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('recording_system_ID'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get ID
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        if (nch.gt.4) then
          write(lu,'("VUNPDAS03 - Terminal ID too long")')
          ierr=-3
        else
          idumy = ichmv_ch(lidter,1,cout(1:nch))
        endif
      endif
C
C  4. Terminal name, 8 characters.
C
      ierr = 4
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('recording_system_name'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get name
        NCH = fvex_len(cout)
        IF  (NCH.GT.8.or.NCH.le.0) THEN  !
          write(lu,'("VUNPDAS04 - Terminal name too long")')
          ierr=-4
        else
          IDUMY = ICHMV_ch(lnater,1,cout(1:NCH))
        endif
      endif
C
C  5. Number of headstacks at this station.

      ierr = 5
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('headstack'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get headstack number 
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i) ! convert to binary
        if (i.le.0.or.iret.ne.0.or.i.gt.2) then
          write(lu,'("VUNPDAS06 - Invalid headstack number:",i5)') i
          ierr=-6
        else
          nstack = i
        endif
      endif
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('headstack'//char(0)),
     .ptr_ch('DAS'//char(0)),0) ! get second headstack statement
      if (iret.eq.0) then ! got a second one
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get headstack number 
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i) ! convert to binary
        if (i.le.0.or.iret.ne.0.or.i.gt.2) then
          write(lu,'("VUNPDAS06a - Invalid headstack number:",i5)') i
          ierr=-6
        else
          nstack = nstack+1
        endif
      endif ! got a second one

C  6. Maximum tape length. If not present, set to default.
C     If recorder type is "S2" then length will be in time units,
C     and speed will follow.
C *** how to handle this?
C
      ierr = 6
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('tape_length'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get tape length
        if (iret.ne.0) return ! must be there
        iret = fvex_units(ptr_ch(cunit),len(cunit))
        if (iret.ne.0) return
        iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d) ! convert to binary
        if (iret.ne.0) return
        if (d.lt.0.d0.or.iret.ne.0) then
          write(lu,'("VUNPDAS07 - Invalid tape length")')
          ierr=-6
        else
          if (.not.ks2) then
            maxtaplen = d*100.d0/(12.d0*2.54) ! convert from m to feet
          else
            maxtaplen = d ! seconds
          endif
        endif
        if (ks2) then ! S2 speed and number of tapes
          iret = fvex_field(2,ptr_ch(cout),len(cout)) ! tape speed
          if (iret.ne.0) return
          NCH = fvex_len(cout)
          IF  (NCH.GT.128.or.NCH.le.0) THEN  !
            write(lu,'("VUNPDAS17 - Tape motion speed too long")')
            ierr=-17
          else
            call c2upper(cout(1:nch),ctemp)
            if (ctemp(1:2).ne.'LP'.and.ctemp(1:3).ne.'SLP') then ! check S2 speed
              write(lu,'("VUNPDAS17 - Invalid S2 speed, must be LP",
     .                  " or SLP")')
              ierr=-19
            else
              IDUMY = ICHMV_ch(ls2sp,1,ctemp(1:NCH))
            endif ! check S2 speed
          endif
          iret = fvex_field(3,ptr_ch(cout),len(cout)) ! number of tapes
          if (iret.ne.0) return
          iret = fvex_int(ptr_ch(cout),i) ! convert to binary
          if (iret.ne.0) return
          if (i.le.0) then
            write(lu,'("VUNPDAS18 - Invalid number of S2 tapes")')
            ierr=-18
          else
            ns2tap = i
          endif
        endif ! S2 speed and number of tapes
      endif
 
C  7. Number of recorders

      ierr = 7
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('number_drives'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get number of recorders
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i) ! convert to binary
        if (iret.ne.0) return
        if (i.le.0) then
          write(lu,'("VUNPDAS08 - Invalid number of recorders")')
          ierr=-7
        else
          nrec = i
        endif
      endif

C  8. Tape motion, early start, late stop, gap time. 

      ierr = 8
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('tape_motion'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! tape motion type
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        IF  (NCH.GT.128.or.NCH.le.0) THEN  !
          write(lu,'("VUNPDAS09 - Tape motion type string error.")')
          ierr=-8
        else
          call c2upper(cout(1:nch),ctapemo)
        endif
        iret = fvex_field(2,ptr_ch(cout),len(cout))  ! early start
        if (iret.eq.0) then 
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d) ! convert to binary
          if (iret.ne.0) return
          if (d.lt.0.0) then
            write(lu,'("VUNPDAS10 - Invalid early start value")')
            ierr=-10
          else
            ite = d ! convert to integer seconds
          endif
        endif 
        iret = fvex_field(3,ptr_ch(cout),len(cout))  ! late stop
        if (iret.eq.0) then 
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d) ! convert to binary
          if (iret.ne.0) return
          if (d.lt.0.0) then
            write(lu,'("VUNPDAS11 - Invalid late stop value")')
            ierr=-11
          else
            itl = d ! convert to integer seconds
          endif
        endif 
        iret = fvex_field(4,ptr_ch(cout),len(cout))  ! time gap
        if (iret.eq.0) then 
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d) ! convert to binary
          if (iret.ne.0) return
          if (d.lt.0.0) then
            write(lu,'("VUNPDAS12 - Invalid gap time value")')
            ierr=-12
          else
            itg = d ! convert to integer seconds
          endif
        endif 
      endif

      iret=0
      if (ierr.gt.0) ierr=0
      return
      end
