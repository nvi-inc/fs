      subroutine get_quik_parnf( rep , intp , cutoff , step )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      integer rep, intp
      real*8  cutoff, step
c
      rep  = nrepnf
      intp = intpnf
c
      cutoff = ctofnf
      step   = stepnf
c
      return
      end
      subroutine get_quik_devnf( dev )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      integer*2 dev(1)
c
      dev(1) = ldv1nf
      dev(2) = ldv2nf
c
      return
      end
      subroutine get_quik_bwsnf( beamwidth )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      real*8 beamwidth(1)
c
      beamwidth(1) = bm1nf_fs
      beamwidth(2) = bm2nf_fs
c
      return
      end
      subroutine get_quik_calnf( caltemp )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      real*8 caltemp(1)
c
      caltemp(1) = cal1nf
      caltemp(2) = cal2nf
c
      return
      end
      subroutine get_quik_caltmp( caltemp , index )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      real*8 caltemp
      integer index
c
      caltemp = caltmp(index)
c
      return
      end
      subroutine get_quik_flxnf( flux )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      real*8 flux(1)
c
      flux(1) = fx1nf_fs
      flux(2) = fx2nf_fs
c
      return
      end







