      SUBROUTINE VGLINP(ivexnum,LU,IERR)

C  This routine gets the experiment information.
C  For now, the experiment name is returned in the call.
C  Call with vmoinp, vstinp, and vsoinp.
C
C History
C 960603 nrv New.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      integer ivexnum,lu
C
C  OUTPUT:
      integer ierr ! error from this routine

C  CALLED BY: 
C  CALLS:  fget_all_station         (get station lines)
C
C  LOCAL:
      character*128 cout
      integer idum,iret,nch,ichmv_ch
      integer fget_global_lowl,fvex_field,ptr_ch,fvex_len

C 1. Get experiment name

      ierr=1
      iret = fget_global_lowl(ptr_ch('exper_name'//char(0)),
     .ptr_ch('EXPER'//char(0)),
     .ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      call ifill(lexper,1,8,oblank)
      if (nch.gt.8) then
        write(lu,'("VEXINP01 - Experiment name too long, using first ",
     .  "8 characters")') 
        nch=8
      endif
      if (nch.gt.0) idum=ichmv_ch(lexper,1,cout(1:nch))

      ierr=0
      return
      end
