      SUBROUTINE vunpfrq(modef,stdef,ivexnum,iret,ierr,lu,
     .bitden,srate,lsg,frf,lsb,cchref,vbw,csw,cbbref,nchandefs)
C
C     VUNPFRQ gets the channel def statements 
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
      double precision srate ! sample rate
      double precision bitden ! bit density
      integer*2 lsg(max_chan) ! subgroup
      double precision frf(max_chan) ! RF frequency
      integer*2 lsb(max_chan) ! net SB
      character*6 cchref(max_chan) ! channel ID
      character*6 cbbref(max_chan) ! BBC ref 
      double precision vbw(max_chan) ! video bandwidth
      character*3 csw(max_chan) ! switching
      integer nchandefs ! number of channel defs found
C
C  LOCAL:
      character*128 cout,cunit
      double precision d
      character upper
      integer j,idum,ic,nch
      integer ichmv_ch ! function
      integer fvex_double,fvex_len,fvex_int,fvex_field,fget_mode_lowl,
     .fvex_units,ptr_ch,fget_all_lowl
C
C
C  1. Channel def statements
C
      ierr = 1
      iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('chan_def'//char(0)),
     .ptr_ch('FREQ'//char(0)),ivexnum)
      ic=0
      do while (ic.lt.max_chan.and.iret.eq.0) ! get all fanout defs
        ic=ic+1

C  1.1 Subgroup

        ierr = 11
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get subgroup
        if (iret.ne.0) return
        idum = ichmv_ch(lsg(ic),1,'- ') ! initialize
        NCH = fvex_len(cout)
        if (nch.gt.1) then
          ierr = -1
          write(lu,'("VUNPFRQ02 - Band ID must be 1 character.")')
        else if (nch.eq.1) then
          idum = ichmv_ch(lsg(ic),1,cout(1:1))
        endif
C
C  1.2 Polarization -- skip this for now

C  1.3 RF frequency

        ierr = 13
        frf(ic)=0.d0
        iret = fvex_field(3,ptr_ch(cout),len(cout)) ! get frequency
        if (iret.ne.0) return
        iret = fvex_units(ptr_ch(cunit),len(cunit))
        if (iret.ne.0) return
        iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
        IF  (d.lt.0.d0) then
          write(lu,'("VUNPFRQ03 - Invalid RF frequency < 0")')
          ierr=-3
        else
          frf(ic) = d/1.d6
        ENDIF 

C  1.4 Net SB

        ierr = 14
        iret = fvex_field(4,ptr_ch(cout),len(cout)) ! get sideband
        if (iret.ne.0) return
        idum = ichmv_ch(lsb(ic),1,'  ')
        cout(1:1) = upper(cout(1:1))
        if (cout(1:1).ne.'U'.and.cout(1:1).ne.'L') then
          ierr = -4
          write(lu,'("VUNPFRQ04 - Invalid sideband field.")')
        else
          idum = ichmv_ch(lsb(ic),1,cout(1:1))
        endif

C  1.5 Bandwidth

        ierr = 15
        iret = fvex_field(5,ptr_ch(cout),len(cout)) ! get bandwidth
        if (iret.ne.0) return
        iret = fvex_units(ptr_ch(cunit),len(cunit))
        if (iret.ne.0) return
        vbw(ic)=0.d0
        iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d) ! convert to binary
        if (iret.ne.0.or.d.lt.0.d0) then
          ierr = -5
          write(lu,'("VUNPFRQ05 - Invalid  bandwidth")')
        else
          vbw(ic) = d/1.d6
        endif

C  1.6 Channel ID

        ierr = 16
        iret = fvex_field(6,ptr_ch(cout),len(cout)) ! get channel ID
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.gt.len(cchref(ic)).or.nch.le.0) then
          ierr=-6
          write(lu,'("VUNPFRQ06 - Channel ID too long")')
        else
          cchref(ic)=cout(1:nch)
        endif

C  1.7 BBC ref

        ierr = 17
        iret = fvex_field(7,ptr_ch(cout),len(cout)) ! get BBC ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.gt.len(cbbref(ic)).or.nch.le.0) then
          ierr=-7
          write(lu,'("VUNPFRQ07 - BBC ref too long")')
        else
          cbbref(ic)=cout(1:nch)
        endif

C  1.8 Phase cal -- skip

C  1.9 Switching

        ierr = 19
        csw(ic)='   ' ! initialize to blank
        iret = fvex_field(9,ptr_ch(cout),len(cout)) ! get switch
        if (iret.eq.0) then ! some switching, 1st switch
          iret = fvex_int(ptr_ch(cout),j)
          if (iret.ne.0.or.j.ne.1.or.j.ne.2) then
            ierr=-8
            write(lu,'("VUNPFRQ08 - Switching cycle must be 0,1,2")')
          else
            csw(ic)(1:1)=cout(1:1)
          endif
          iret = fvex_field(10,ptr_ch(cout),len(cout)) ! get 2nd switch
          if (iret.eq.0) then ! second cycle
            iret = fvex_int(ptr_ch(cout),j)
            if (iret.ne.0.or.j.ne.1.or.j.ne.2) then
              ierr=-8
              write(lu,'("VUNPFRQ08 - Switching cycle must be 0,1,2")')
            else
              csw(ic)(2:2)=','
              csw(ic)(3:3)=cout(1:1)
            endif
          endif ! second cycle
          iret = fvex_field(11,ptr_ch(cout),len(cout)) ! get switch
          if (iret.eq.0)
     .    write(lu,'("VUNPFR09 - Too many switching cycles, 2 is max")')
        endif ! some switching

C       Get next channel def statement
        iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('chan_def'//char(0)),
     .  ptr_ch('FREQ'//char(0)),0)
      enddo ! get all channel defs
      nchandefs = ic

C 2. Bit density

        ierr = 2
        iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('record_density'//char(0)),
     .  ptr_ch('DAS'//char(0)),ivexnum)
        bitden=0.d0
        if (iret.eq.0) then
          iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get number
          if (iret.ne.0) return
          iret = fvex_int(ptr_ch(cout),j)
          if (iret.ne.0.or.j.lt.0) then
            ierr=-9
            write(lu,'("VUNPFRQ09 - Invalid bit density")')
          else
            bitden = j
          endif
        endif

C 3. Sample rate

        ierr = 3
        iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('sample_rate'//char(0)),
     .  ptr_ch('FREQ'//char(0)),ivexnum)
        srate=0.d0
        if (iret.eq.0) then
          iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get number
          if (iret.ne.0) return
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (iret.ne.0.or.d.lt.0.d0) then
            ierr=-10
            write(lu,'("VUNPFRQ10 - Invalid sample rate")')
          else
            srate = d/1.d6
          endif
        endif

      if (ierr.gt.0) ierr=0
      return
      end
