      SUBROUTINE VGLINP(ivexnum,LU,IERR,iret)

C  This routine gets the experiment information.
C  For now, the experiment name, description and PI name are put
C  in common.
C  Called by drudg/SREAD. 
C
C History
C 960603 nrv New.
C 970124 nrv Add iret to call.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      integer ivexnum,lu
C
C  OUTPUT:
      integer ierr ! error from this routine

C  CALLED BY: 
C  CALLS:  fget_global_lowl         (get global info)
C
C  LOCAL:
      character*128 cout
      integer idum,iret,nch,ichmv_ch
      integer fget_global_lowl,fvex_field,ptr_ch,fvex_len

C Initialize.

      call ifill(lexper,1,8,oblank)
      cexperdes=' '
      cpiname=' '
      ccorname=' '

C 1. Get experiment name

      ierr=1
      iret = fget_global_lowl(ptr_ch('exper_name'//char(0)),
     .ptr_ch('EXPER'//char(0)),
     .ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      if (nch.gt.8) then
        write(lu,'("VEXINP01 - Experiment name too long, using first ",
     .  "8 characters")') 
        nch=8
      endif
      if (nch.gt.0) idum=ichmv_ch(lexper,1,cout(1:nch))

C 2. Get experiment description

      ierr=2
      iret = fget_global_lowl(ptr_ch('exper_description'//char(0)),
     .ptr_ch('EXPER'//char(0)),
     .ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      if (nch.gt.128) then
        write(lu,'("VEXINP02 - Experiment description too long, ",
     .  "using first 128 characters")') 
        nch=128
      endif
      if (nch.gt.0) cexperdes=cout(1:nch)

C 3. Get PI name

      ierr=3
      iret = fget_global_lowl(ptr_ch('PI_name'//char(0)),
     .ptr_ch('EXPER'//char(0)),
     .ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      if (nch.gt.128) then
        write(lu,'("VEXINP03 - PI name too long, ",
     .  "using first 128 characters")') 
        nch=128
      endif
      if (nch.gt.0) cpiname=cout(1:nch)

C 4. Get correlator

      ierr=4
      iret = fget_global_lowl(ptr_ch('target_correlator'//char(0)),
     .ptr_ch('EXPER'//char(0)),
     .ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      nch=fvex_len(cout)
      if (nch.gt.128) then
        write(lu,'("VEXINP04 - Correlator name too long, ",
     .  "using first 128 characters")') 
        nch=128
      endif
      if (nch.gt.0) ccorname=cout(1:nch)

      ierr=0
      return
      end
