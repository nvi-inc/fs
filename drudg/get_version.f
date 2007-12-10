      subroutine get_version(iverMajor,iverMinor,iverPatch)
      integer*2 iverMajor,iverMinor,iverPatch

! below is set at compiletime
      iVerMajor = VERSION
      iVerMinor = SUBLEVEL
      iVerPatch = PATCHLEVEL
!      iVerMajor = 09
!      iVerMinor = 08
!      iVerPatch = 02
C Initialize the version date.

! return to calling program.
      return
      end
