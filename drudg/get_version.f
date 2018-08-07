      subroutine get_version(iverMajor,iverMinor,iverPatch,crel_FS)
      implicit none 
      integer*2 iverMajor,iverMinor,iverPatch
      character*32 crel_FS
! local
      integer j
      integer ind

! below is set at compiletime on Unix systems. must be set by hand on HPUX
      iVerMajor = VERSION
      iVerMinor = SUBLEVEL
      iVerPatch = PATCHLEVEL  
      crel_FS=" "
      call crelease(crel_FS)   

! Replace NULL with space 
      ind=index(crel_fs,char(0))
      write(*,*) ind 
      do while(ind .ne. 0) 
         crel_fs(ind:ind)=" "
         ind=index(crel_fs,char(0))
      end do 

      
!      iVerMajor = 09
!      iVerMinor = 10  
!      iVerPatch = 05
C Initialize the version date.

! return to calling program.
      return
      end
