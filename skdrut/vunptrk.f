      SUBROUTINE vunptrk(modef,stdef,ivexnum,iret,ierr,lu,
     .lm,cp,cchref,csm,itrk,nfandefs,ihdn,ifanfac)
C
C     VUNPTRK gets the track assignments and fanout information
C     for station STDEF and mode MODEF and converts it.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
C
C  History:
C 960520 nrv New.
C 961122 nrv Change fget_mode_lowl to fget_all_lowl
C 970124 nrv Move initialization to start.
C 970206 nrv Change max_pass to max_track as size of arrays in fandefs
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
      integer*2 lm(4) ! recording format
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
C  Initialize
C
      CALL IFILL(LM,1,8,oblank)
      do in=1,max_track
        cp(in)=' '
        cchref(in)=''
        csm(in)=' '
        itrk(in)=0
        ihdn(in)=0
      enddo
      nfandefs=0
      ifanfac=0

C  1. The recording format
C
      ierr = 1
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('track_frame_format'//char(0)),
     .ptr_ch('TRACKS'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      NCH = fvex_len(cout)
      IF  (NCH.GT.8.or.NCH.le.0) THEN  !
        write(lu,'("VUNPTRK01 - Track format name too long")')
        iret=-1
      else
        IDUMY = ICHMV_ch(LM,1,cout(1:NCH))
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
          write(lu,'("VUNPTRK02 - Subpass must be 1 character.")')
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
          write(lu,'("VUNPTRK03 - Channel ref name too long")')
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
          write(lu,'("VUNPTRK04 - Invalid sign/magnitude field.")')
        else
          csm(in) = cout(1:1)
        endif

C  2.4 Headstack number

        ierr = 24
        iret = fvex_field(4,ptr_ch(cout),len(cout)) ! get headstack number
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i) ! convert to binary
        if (i.lt.0.or.i.gt.max_headstack) then
          ierr = -5
          write(lu,'("VUNPTRK05 - Invalid headstack number, must be",
     .    "between 1 and ",i3)') max_headstack
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
            if (j.lt.0.or.j.gt.max_track) then
              ierr = -6
              write(lu,'("VUNPTRK06 - Invalid track number ",i3,
     .        "must be between 1 and ",i3)') j,max_track
            else
              it(i-4)=j
              if (i.eq.5) itrk(in)=j ! save the first one only
            endif
          endif ! a track
          i=i+1
        enddo
        iret = fvex_field(10,ptr_ch(cout),len(cout)) ! get track
        if (iret.eq.0) 
     .  write(lu,'("VUNPTRK16 - Too many fanout tracks, max is 4")')

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
            write(lu,'("VUNPTRK07 - Inconsistent fanout defs.")')
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
