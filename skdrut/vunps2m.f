      SUBROUTINE vunps2m(modef,stdef,ivexnum,iret,ierr,lu,
     .ls2m,ls2d,cp,cchref,csm,itrk,nfandefs,ihdn,ifanfac)
C
C     VUNPS2M gets the S2 mode from the $TRACKS section 
C     for station STDEF and mode MODEF. 
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
C
C  History:
C 960817 nrv New.
C 961122 nrv Change fget_mode_lowl to fget_all_lowl
C 970117 nrv Remove "track_frame_format", irrelevant for S2.
C 970124 nrv Remove "lsm" from call.
C 021111 jfq Add ls2d,cp,cchref,csm,itrk,nfandefs,ihdn,ifanfac
C            - supporting S2_data_source and fanout_def
C
C  INPUT:
      character*128 stdef ! station def to get
      character*128 modef ! mode def to get
      integer ivexnum ! vex file ref
      integer lu ! unit for writing error messages
C
C  OUTPUT:
      integer iret ! error return from vex routines, !=0 is error
      integer ierr ! error from this routine, >0 indicates the
C                    statement to which the VEX error refers,
C                    <0 indicates invalid value for a field
      integer*2 ls2m(8) ! recording format
      integer*2 ls2d(4) ! data source
      character*1 cp(max_track) ! subpass
      character*6 cchref(max_track) ! channel ID ref
      character*1 csm(max_track) ! sign/mag
      integer ihdn(max_track) ! headstack number
      integer itrk(max_track) ! first track of the fanout assignment
      integer nfandefs ! number of def statements
      integer ifanfac ! fanout factor determined from list of tracks
C
C  LOCAL:
      character*128 cout
      integer it(4),j,nn,in,i,nch,idumy
      integer ichmv_ch ! function
      integer fvex_len,fvex_int,fvex_field,fget_all_lowl,ptr_ch
C
C    Initialize.
      CALL IFILL(Ls2M,1,16,oblank)
      CALL IFILL(Ls2D,1,8,oblank)
      do in=1,max_track
        cp(in)=' '
        cchref(in)=''
        csm(in)=' '
        itrk(in)=0
        ihdn(in)=0
      enddo
      nfandefs=0
      ifanfac=0
C
C  1. The S2 record mode
C
      ierr = 1
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('S2_recording_mode'//char(0)),
     .ptr_ch('TRACKS'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      NCH = fvex_len(cout)
      IF  (NCH.GT.8.or.NCH.le.0) THEN  !
        write(lu,'("VUNPS2M01 - Record mode name too long")')
        iret=-1
      else
        IDUMY = ICHMV_ch(LS2M,1,cout(1:NCH))
      END IF  !
C
C  1a. The S2 data source
C
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('S2_data_source'//char(0)),
     .ptr_ch('TRACKS'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      NCH = fvex_len(cout)
      IF  (NCH.GT.4.or.NCH.le.0) THEN  !
        write(lu,'("VUNPS2M01 - data source name too long")')
        iret=-1
      else
        IDUMY = ICHMV_ch(LS2D,1,cout(1:NCH))
      END IF  !
C
C  2. Fanout def statements
C
      ierr = 2
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('fanout_def'//char(0)),
     .ptr_ch('TRACKS'//char(0)),ivexnum)
      in=0
      do while (in.lt.max_pass.and.iret.eq.0) ! get all fanout defs
        in=in+1 ! number of fanout defs

C  2.1 Subpass

        ierr = 21
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get subpass
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        if (nch.ne.1) then
          ierr = -2
          write(lu,'("VUNPS2M02 - Subpass must be 1 character.")')
        else
          cp(in) = cout(1:1)
        endif
C
C  2.2 Chan ref

        ierr = 22
        iret = fvex_field(2,ptr_ch(cout),len(cout)) ! get channel ref
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        IF  (NCH.GT.len(cchref(1)).or.NCH.le.0) THEN  !
          write(lu,'("VUNPS2M03 - Channel ref name too long")')
          ierr=-3
        else
          cchref(in) = cout(1:nch)
        ENDIF 

C  2.3 Sign/magnitude

        ierr = 23
        iret = fvex_field(3,ptr_ch(cout),len(cout)) ! get sign/mag
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        if (cout(1:1).ne.'s'.and.cout(1:1).ne.'m') then
          ierr = -4
          write(lu,'("VUNPS2M04 - Invalid sign/magnitude field.")')
        else
          csm(in) = cout(1:1)
        endif

C  2.4 Headstack number

        ierr = 24
        iret = fvex_field(4,ptr_ch(cout),len(cout)) ! get headstack number
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i) ! convert to binary
        if (i.le.0.or.i.gt.1) then
          ierr = -5
          write(lu,'("VUNPS2M05 - Invalid headstack number",i3,
     .    ", must be 1")') i
        else
          ihdn(in) = i
        endif

C  2.5 Track list

        ierr = 25
        do i=1,4
          it(i)=-99
        enddo
        i=5 ! fields 5 through 8 may have tracks
        do while (i.le.9.and.iret.eq.0) ! get tracks
          iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get track
          if (iret.eq.0) then ! a track
            iret = fvex_int(ptr_ch(cout),j) ! convert to binary
            if (j.lt.0.or.j.gt.15) then
              ierr = -6
              write(lu,'("VUNPS2M06 - Invalid track number ",i3,
     .        "must be between 0 and 15")') j,max_track
            else
              it(i-4)=j+1
              if (i.eq.5) itrk(in)=j+1 ! save the first one only
            endif
          endif ! a track
          i=i+1
        enddo
        iret = fvex_field(10,ptr_ch(cout),len(cout)) ! get track
        if (iret.eq.0) 
     .  write(lu,'("VUNPS2M16 - Too many fanout tracks, max is 4")')

C       Check for consistent fanout
        nn=0
        do j=1,4
          if (it(j).ne.-99) nn=nn+1 ! count the fanned tracks
        enddo
        if (in.eq.1) then 
          ifanfac=nn ! save first fanout value
        else ! check subsequent ones
          if (nn.ne.ifanfac) then
            ierr = -7
            write(lu,'("VUNPS2M07 - Inconsistent fanout defs.")')
          endif
        endif ! save first/check subsequent defs
        
C       Get next fanout def statement
        iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('fanout_def'//char(0)),
     .  ptr_ch('TRACKS'//char(0)),0)
      enddo ! get all fanout defs
      nfandefs = in

      if (ierr.gt.0) ierr=0
      return
      end
