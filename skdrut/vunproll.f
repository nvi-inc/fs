      SUBROUTINE vunproll(modef,stdef,ivexnum,iret,ierr,lu,
     .croll)
C
C     VUNPROLL gets the barrel roll definitions 
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
C 961020 nrv New. 
C 970128 nrv Cleanup on initialization. Add max_headstack.
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
      character*4 croll ! either 8:1 or 16:1 or off
C
C  LOCAL:
      character*128 cout
      integer i,it(max_track),in,iroll,maxroll,j,nn,ifield
      integer fvex_len,fvex_int,fvex_field,fget_all_lowl,ptr_ch
C
C  Initialize maxroll here. When more complex patterns are handled,
C  this should be in the parameters file.
      maxroll=16

C  1. Roll on or off -- not there in version 1.3

      ierr = 1
      croll = '    '
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('roll'//char(0)),
     .ptr_ch('ROLL'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get roll
      if (fvex_len(cout).gt.4) then
        ierr = -1
        write(lu,'("VUNPROLL01 - Roll must be on or off.")')
      else
        croll = cout(1:fvex_len(cout))
      endif
      if (ierr.gt.0) ierr=0
      if (croll.eq.'off') return ! no more to do
C
C  2. Roll def statements. "roll" statements in version 1.3
C
      ierr = 2
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('roll_def'//char(0)),
     .ptr_ch('ROLL'//char(0)),ivexnum)
      in=0
      do while (in.lt.max_track.and.iret.eq.0) ! get all roll defs
        in=in+1 ! number of roll defs

C  2.1 Headstack. Checked but not saved. 

        ierr = 21
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get headstack
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),j) ! convert to binary
        if (j.lt.0.or.j.gt.max_headstack) then
          ierr = -1
          write(lu,'("VUNPROLL01 - Only ",i2," headstacks supported.")')
        endif
C
C  2.2 Home track. Checked but not saved.

        ierr = 22
        iret = fvex_field(2,ptr_ch(cout),len(cout)) ! get home track
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),j) ! convert to binary
        IF  (j.lt.0.or.j.gt.max_track) then
          write(lu,'("VUNPROLL03 - Invalid home track.")')
          ierr=-3
        ENDIF 

C  2.3 Track list. Checked and counted.

        ierr = 23
        do i=1,max_track
          it(i)=-99
        enddo
        ifield=3 ! fields 3 through maxroll+2 may have tracks
        do while (ifield.le.maxroll+2.and.iret.eq.0) ! get tracks
          iret = fvex_field(ifield,ptr_ch(cout),len(cout)) ! get track
          if (iret.eq.0) then ! a track
            iret = fvex_int(ptr_ch(cout),j) ! convert to binary
            if (j.lt.0.or.j.gt.max_track) then
              ierr = -6
              write(lu,'("VUNPROLL03 - Invalid roll track number ",i3,
     .        "must be between 1 and ",i3)') j,max_track
            else
              it(ifield-2)=j
            endif
          endif ! a track
          ifield=ifield+1
        enddo

C       Check for consistent fanout
        nn=0
        do j=1,max_track
          if (it(j).ne.-99) nn=nn+1 ! count the rolled tracks
        enddo
        if (in.eq.1) then 
          iroll=nn ! save first roll value
          if (nn.eq.8) then
            croll='8:1 '
          else if (nn.eq.16) then
            croll='16:1'
          else
            write(lu,'("VUNPROLL07 - Only roll by 8 or 16 supported.")')
          endif
        else ! check subsequent ones
          if (nn.ne.iroll) then
            ierr = -7
            write(lu,'("VUNPROLL03 - Inconsistent roll defs.")')
          endif
        endif ! save first/check subsequent defs
        
C       Get next roll def statement
        iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('roll'//char(0)),
     .  ptr_ch('ROLL'//char(0)),0)
      enddo ! get all roll defs

      if (in.eq.0) croll = 'off '
      if (ierr.gt.0) ierr=0
      return
      end
