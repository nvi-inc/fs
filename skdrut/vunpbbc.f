      SUBROUTINE vunpbbc(modef,stdef,ivexnum,iret,ierr,lu,
     .cbbref,ivc,cifref,nbbcdefs)
C
C     VUNPBBC gets the BBC assignment statements 
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
C 960522 nrv New.
C 961122 nrv change fget_mode_lowl to fget_all_lowl
C 970124 nrv Move initialization to front.
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
      character*(*) cbbref(max_bbc) ! BBC assignment refs
      integer ivc(max_bbc) ! physical BBC number
      character*(*) cifref(max_bbc) ! IFD refs
      integer nbbcdefs ! number of BBCs found
C
C  LOCAL:
      character*128 cout
      integer ib,i,nch
      integer fvex_int,fvex_len,fvex_field,fget_all_lowl,ptr_ch
C
C  Initialize.

      nbbcdefs=0
      do i=1,max_bbc
        cbbref(i)=''
        ivc(i)=0
        cifref(i)=''
      enddo
C
C  1. BBC assignment statements
C
      ierr = 1
      ib=0
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('BBC_assign'//char(0)),
     .ptr_ch('BBC'//char(0)),ivexnum)
      do while (ib.lt.max_bbc.and.iret.eq.0) ! get all BBC defs
        ib=ib+1

C  1.1 BBC ref

        ierr = 11
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get BBC ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.gt.len(cbbref(ib)).or.nch.le.0) then
          ierr=-1
          write(lu,'("VUNPBBC01 - BBC ref too long")')
        else
          cbbref(ib)=cout(1:nch)
        endif

C  1.2 Physical BBC #

        ierr = 12
        iret = fvex_field(2,ptr_ch(cout),len(cout)) ! get number
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i)
        if (iret.ne.0.or.i.le.0.or.i.gt.max_bbc) then
          ierr=-2
          write(lu,'("VUNPFRQ02 - Invalid BBC number ",i5,", must "
     .    "be between 1 and ",i3)') i,max_bbc
        else
          ivc(ib) = i
        endif

C  1.3 IFD ref

        ierr = 13
        iret = fvex_field(3,ptr_ch(cout),len(cout)) ! get IFD ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.gt.len(cifref(ib)).or.nch.le.0) then
          ierr=-3
          write(lu,'("VUNPBBC03 - IFD ref too long")')
        else
          cifref(ib)=cout(1:nch)
        endif

C       Get next BBC def statement
        iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('BBC_assign'//char(0)),
     .  ptr_ch('BBC'//char(0)),0)
      enddo ! get all BBC defs
      nbbcdefs = ib

      if (ierr.gt.0) ierr=0
      return
      end
