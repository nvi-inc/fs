      subroutine get_version(iverMajor,iverMinor,iverPatch)
      integer*2 iverMajor,iverMinor,iverPatch

! below is set at compiletime on Unix systems. must be set by hand on HPUX
      iVerMajor = VERSION
      iVerMinor = SUBLEVEL
      iVerPatch = PATCHLEVEL
!      iVerMajor = 09
!      iVerMinor = 10  
!      iVerPatch = 05
C Initialize the version date.

! return to calling program.
      return
      end
