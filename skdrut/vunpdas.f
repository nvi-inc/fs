      SUBROUTINE VUNPDAS(stdef,ivexnum,iret,ierr,lu,
     .lidter,lnater,nheadstack,maxtap,nrec,lb,sefd,par,npar,
     .lrec,lrack)
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
C
C  LOCAL:
      character*128 cout,cunit
      double precision d
      integer i,nch,idumy
      integer fvex_double,fvex_int,fget_station_lowl,fvex_field,
     .fvex_units,
     .ptr_ch,fvex_len,ichmv_ch ! function
C
C
C  1. The recorder type
C
      ierr=1
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('record_transport'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      CALL IFILL(lrec,1,8,oblank)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get recorder name
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        IF  (NCH.GT.8.or.NCH.le.0) THEN  !
          write(lu,'("VUNPDAS01 - Recorder type name too long")')
          ierr=-1
        else
          IDUMY = ICHMV_ch(lrec,1,cout(1:NCH))
        endif
      endif

C  2. The rack type
C
      ierr = 2
      CALL IFILL(lrack,1,8,oblank)
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('electronics_rack'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get rack name
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        IF  (NCH.GT.8.or.NCH.le.0) THEN  !
          write(lu,'("VUNPDAS02 - Rack type name too long")')
          ierr=-2
        else
          IDUMY = ICHMV_ch(lrack,1,cout(1:nch))
        endif
      endif
C
C  3. The terminal ID. 
C
      ierr = 3
      idumy = ichmv_ch(lidter,1,'    ')
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
      CALL IFILL(lnater,1,8,oblank)
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
      nheadstack=1 ! default
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
C
      ierr = 6
      maxtap = MAX_TAPE
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('tape_length'//char(0)),
     .ptr_ch('DAS'//char(0)),ivexnum)
      if (iret.eq.0) then
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get tape length
        if (iret.ne.0) return
        iret = fvex_units(ptr_ch(cunit),len(cunit))
        if (iret.ne.0) return
        iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d) ! convert to binary
        if (iret.ne.0) return
        if (d.lt.0.d0.or.iret.ne.0) then
          write(lu,'("VUNPDAS07 - Invalid tape length")')
          ierr=-7
        else
          maxtap = d*100.d0/(12.d0*2.54)
        endif
      endif
 
C  7. Number of recorders

      ierr = 7
      nrec = 1
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
          ierr=-8
        else
          nrec = i
        endif
      endif

      if (ierr.gt.0) ierr=0
      return
      end
