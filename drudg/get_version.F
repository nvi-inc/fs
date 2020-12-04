*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine get_version(iverMajor,iverMinor,iverPatch,crel_FS)
      implicit none 
      integer*2 iverMajor,iverMinor,iverPatch
      character*32 crel_FS
! local
     
      integer ind

! below is set at compiletime on Unix systems. must be set by hand on HPUX
      iVerMajor = VERSION
      iVerMinor = SUBLEVEL
      iVerPatch = PATCHLEVEL  
      crel_FS=" "
      call crelease(crel_FS)   

! Replace NULL with space 
      ind=index(crel_fs,char(0))
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
