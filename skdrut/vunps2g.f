      SUBROUTINE vunps2g(modef,stdef,ivexnum,iret,ierr,lu,
     .cpassl,npassl)
C
C     VUNPS2G gets the group order for S2 recorders 
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
      character*3 cpassl(max_pass) ! list of groups
      integer npassl ! number of groups found
C
C  LOCAL:
      character*128 cout
      integer il,i
      integer fvex_len,fvex_field,fget_mode_lowl,ptr_ch,
     .fget_all_lowl
C
C
C  1. Pass order list
C
      npassl=0
      ierr = 1
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('S2_group_order'//char(0)),
     .ptr_ch('PASS_ORDER'//char(0)),ivexnum)
C     iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
C    .ptr_ch('pass_order'//char(0)),
C    .ptr_ch('PASS_ORDER'//char(0)),ivexnum)
      if (iret.ne.0) return

C  1.1 <group>

      ierr = 11
      i=1
      do while (i.le.max_pass.and.iret.eq.0)
        iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get field 
        if (iret.eq.0) then
          il=fvex_len(cout)
          cpassl(i)=cout(1:il) ! save the pass-order list
          i=i+1
        endif
      enddo
      npassl = i-1

      if (ierr.gt.0) ierr=0
      return
      end
