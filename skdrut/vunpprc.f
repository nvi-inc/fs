      SUBROUTINE vunpprc(modef,stdef,ivexnum,iret,ierr,lu,
     .lpre)
C
C     VUNPPRE gets the procedure prefix if any 
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
C 970114 nrv New.
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
      integer*2 lpre(4) ! prefix
C
C  LOCAL:
      character*128 cout
      integer idum,nch
      integer ichmv_ch ! function
      integer ifill,fvex_len,ptr_ch,fget_all_lowl,fvex_field
C
C
C  1. Prefix.
C
      ierr = 1
      idum = ifill(lpre,1,8,oblank) ! initialize
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('procedure_name_prefix'//char(0)),
     .ptr_ch('PROCEDURES'//char(0)),ivexnum)
      if (iret.eq.0) then ! got one
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get prefix
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        if (nch.gt.8) then
          ierr = -1
          write(lu,'("VUNPPRC01 - Prefix must be <=8 characters.")')
        else 
          idum = ichmv_ch(lpre,1,cout(1:nch))
        endif
      endif ! got one

      if (ierr.gt.0) ierr=0
      return
      end
