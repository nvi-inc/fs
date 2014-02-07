      SUBROUTINE vunpif(modef,stdef,ivexnum,iret,ierr,lu,
     .cifref,flo,cs,cin,cp,fpcal,fpcal_base,nifdefs)
C
C     VUNPIF gets the IFD def statements 
C     for station STDEF and mode MODEF and converts it.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
! functions
      integer iwhere_in_string_list
      character upper
      integer fvex_len,fvex_field,ptr_ch,fvex_double
      integer fvex_units,fget_all_lowl
C
C  History:
C 960522 nrv New.
C 970114 nrv For Vex 1.5 get IF name from def directly instead of ref name, 
C            and add polarization to call.
C 970124 nrv Move initialization to front.
C 971208 nrv Add phase cal spacing and base frequency. 
C 990910 nrv Change default LO value to -1.0 meaning none.
C 991110 nrv Allow IF type 3N to be valid.
! 2004Oct19 JMGipson.  Removed warning message if LO was negative.
! 2006Oct06 JMGipson.  changed ls,lin,lp --> (ASCII) cs,cin,cp
!                      Made IF="1" a valid choice. An S2 VEX schedule had this.
! 2012Sep17 JMGipson.  Madef a1,a2..a4,...d4 valid choices since this is what DBBCs expect.
!            Also if an unrecognized value, issue warning message but leave alone. 
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
      character*6 cifref(max_ifd) ! IFD refs
      double precision flo(max_ifd) ! LO frequencies
      double precision fpcal(max_ifd) ! pcal frequencies
      double precision fpcal_base(max_ifd) ! pcal_base frequencies
      character*2 cs(max_ifd) ! sideband of the LO
      character*2 cin(max_ifd) ! IF input channel
      character*2 cin_tmp
      character*2 cp(max_ifd) ! polarization
      integer iwhere                !where in a list.
      integer nifdefs ! number of IFDs found

      integer num_valid_if
      parameter (num_valid_if=29)
      character*2 cvalid_if(num_valid_if) 

C
C  LOCAL:
      character*128 cout,cunit
      double precision d
      integer id,nch
      data cvalid_if/"A", "B", "C", "D", "1",     !5
     >   "1N","1A","2N","2A","3N","3A","3O","3I", !8
     >   "A1","A2","A3","A4","B1","B2","B3","B4", !8
     >   "C1","C2","C3","C4","D1","D2","D3","D4"/ !8

C
C  Initialize
      nifdefs=0
      do id=1,max_ifd
        cifref(id)=''
        flo(id)=-1.d0 ! defaults to no LO
        fpcal(id)=-1.d0 ! defaults to off
        fpcal_base(id)=0.d0
        cs(id)=" "
        cp(id)=" "
        cin(id)=" "
      enddo
C
C  1. IFD def statements
C
      ierr = 1
C ** this should work with fget_mode_lowl but doesn't seem to
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     >  ptr_ch('if_def'//char(0)),ptr_ch('IF'//char(0)),ivexnum)
      id=0
      do while (id.lt.max_ifd.and.iret.eq.0) ! get all IF defs
        id=id+1

C  1.1 IF def

        ierr = 11
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get IFD ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.gt.len(cifref(id)).or.nch.le.0) then
          ierr=-1
          write(lu,'("VUNPIF01 - IFD ref too long")')
        else
          cifref(id)=cout(1:nch)
        endif

C  1.2 IF input
  
        ierr = 12
        iret = fvex_field(2,ptr_ch(cout),len(cout)) ! get input
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.ne.1.and.nch.ne.2) then
          ierr=-2
          write(lu,'(a)')
     >       "VUNPIF04 - IF input must be 1 or 2 characters"
        else
          cin(id)=cout(1:nch) 
          cin_tmp=cin(id) 
          call capitalize(cin_tmp)
          iwhere=iwhere_in_string_list(cvalid_if,num_valid_if,cin_tmp) 
          if(iwhere .eq. 0) then                     
            write(lu,'("VUNPIF05: Warning. Unrecognized IF ",a)') 
     >        cin(id)
          endif
        endif

C  1.3 Polarization 

        ierr = 13
        iret = fvex_field(3,ptr_ch(cout),len(cout)) ! get IFD ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        cout(1:1) = upper(cout(1:1))
        if (nch.ne.1.or.(cout(1:1).ne.'R'.and.cout(1:1).ne.'L')) then
          ierr=-3
          write(lu,'("VUNPIF06 - Polarization must be R or L")')
        else
          cp(id)=cout(1:1)
        endif

C  1.4 LO frequency

        ierr = 14
        iret = fvex_field(4,ptr_ch(cout),len(cout)) ! get number
        if (iret.ne.0) return
        iret = fvex_units(ptr_ch(cunit),len(cunit))
        if (iret.ne.0) return
        iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
        if (iret.ne.0.or.d.lt.0.d0) then
!          ierr=-4
!          write(lu,'("VUNPIF02 - Invalid LO frequency",d10.2)') d
        else
          flo(id) = d/1.d6
        endif

C  1.5 Sideband

        ierr = 15
        iret = fvex_field(5,ptr_ch(cout),len(cout)) ! get IFD ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        cout(1:1) = upper(cout(1:1))
        if (nch.ne.1.or.(cout(1:1).ne.'U'.and.cout(1:1).ne.'L')) then
          ierr=-5
          write(lu,'("VUNPIF03 - Sideband must be U or L")')
        else
          cs(id)=cout(1:1)
        endif

C  1.6 Phase cal spacing

        ierr = 16
        iret = fvex_field(6,ptr_ch(cout),len(cout)) ! get pcal spacing
        if (iret.eq.0) then ! got one
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (iret.ne.0.or.d.lt.0.d0) then
            ierr=-6
            write(lu,'("VUNPIF04 - Invalid phase cal frequency",
     .          d10.2)') d
          else
            fpcal(id) = d/1.d6 ! convert to MHz
          endif
        endif ! got one

C  1.7 Phase cal base

        ierr = 17
        iret = fvex_field(7,ptr_ch(cout),len(cout)) ! get pcal base
        if (iret.eq.0) then ! got one
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (iret.ne.0.or.d.lt.0.d0) then
            ierr=-7
            write(lu,'("VUNPIF05 - Invalid phase cal base frequency",
     .          d10.2)') d
          else
            fpcal_base(id) = d/1.d6 ! convert to MHz
          endif
        endif ! got one

C       Get next IFD def statement
        iret = fget_all_lowl(ptr_ch(stdef),
     .  ptr_ch(modef),ptr_ch('if_def'//char(0)),
     .  ptr_ch('IF'//char(0)),0)
      enddo ! get all BBC defs
      iret=0
      nifdefs = id

      if (iret.eq.0.and.ierr.gt.0) ierr=0
      return
      end
