      subroutine get_version(iverMajor,iverMinor,iverPatch)
      integer*2 iverMajor,iverMinor,iverPatch

! below is set at compiletime
      iVerMajor = VERSION
      iVerMinor = SUBLEVEL
      iVerPatch = PATCHLEVEL
! return to calling program.
      return
      end
