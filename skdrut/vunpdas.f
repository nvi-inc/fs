      SUBROUTINE VUNPDAS(stdef,ivexnum,iret,ierr,lu,
     .lidter,lnater,nheadstack,maxtap,nrec,lb,sefd,par,npar,
     .lrec,lrack,ctapemo,ite,itl,itg,ls2sp,ns2tap)
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
      integer maxtap,nrec
      integer*2 lidter(2) ! terminal ID
      integer nheadstack ! number of headstacks
      integer*2 LNATER(4) ! name of the terminal
      integer*2 lb(*)  ! bands
      real sefd(*),par(max_sefdpar,*)
      integer npar(*)   ! sefds
      integer*2 lrec(4),lrack(4) ! recorder and rack types
      character*128 ctapemo ! tape motion type
      integer ite,itl,itg ! early, late, gap 
      integer*2 ls2sp(2) ! S2 tape speed
      integer ns2tap ! number of S2 tapes
C
C  LOCAL:
      character*128 cout,cunit
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
      CALL IFILL(lnater,1,8,oblank)
      nheadstack=1 ! default
      maxtap = MAX_TAPE
      CALL IFILL(ls2sp,1,8,oblank)
      ns2tap=0
      nrec = 1 ! default
      ite=0
      itl=0
      itg=0 
      ctapemo=''

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
          if (ichcm_ch(lrec,1,'S2').ne.0.and.
     .        ichcm_ch(lrec,1,'VLBA').ne.0.and.
     .        ichcm_ch(lrec,1,'Mark3A').ne.0.and.
     .        ichcm_ch(lrec,1,'Mark4').ne.0.and.
     .        ichcm_ch(lrec,1,'VLBA4').ne.0) then
            write(lu,'("VUNPDAS22 - Unrecognized recorder type: ",a)')
     .      cout(1:nch)
          endif
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
          if (ichcm_ch(lrack,1,'VLBA').ne.0.and.
     .        ichcm_ch(lrack,1,'VLBAG').ne.0.and.
     .        ichcm_ch(lrack,1,'VLBA4').ne.0.and.
     .        ichcm_ch(lrack,1,'Mark3A').ne.0.and.
     .        ichcm_ch(lrack,1,'Mark4').ne.0 .and.
     .        ichcm_ch(lrack,1,'NONE').ne.0 .and.
     .        ichcm_ch(lrack,1,'none').ne.0) then
            write(lu,'("VUNPDAS22 - Unrecognized rack type: ",a)')
     .      cout(1:nch)
          endif
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
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get number of headstacks
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i) ! convert to binary
        if (i.lt.0.or.iret.ne.0) then
          write(lu,'("VUNPDAS06 - Invalid headstack number")')
          ierr=-6
        else
          nheadstack = i
        endif
      endif

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
            maxtap = d*100.d0/(12.d0*2.54) ! convert from m to feet
          else
            maxtap = d ! seconds
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
            IDUMY = ICHMV_ch(ls2sp,1,cout(1:NCH))
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
