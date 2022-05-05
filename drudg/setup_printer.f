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
      subroutine setup_printer(cpaper_size,coption,csize,
     >    maxwidth,maxline,ierr)
! on input
!     iwidth, csize are defaults width of paper, size of font.
!     coption  -- contains values set by skedf.ctl. One of PL,PS,LL,LS
      implicit none
      character*2 cpaper_size  !set interactively.
      character*2 coption      !set in skedf.ctl
! output
      character*2 csize
      integer maxwidth
      integer maxline
      integer ierr
! local
      integer i
      real rwidth,rheight                !paper size
      real rlines_per_inch,rchars_per_inch !characters, lines per inch
      integer itype
! History
!     2004Nov12 JMGipson  First version.
!     2004Nov17 JMGipson. Modified to return orientation, size.

      csize=cpaper_size
      do i=1,2
        if(cpaper_size(i:i) .eq. "D") csize(i:i)=coption(i:i)
      end do

      itype=0
      if(csize(1:1).eq."L") then
        rwidth=10.0                !leave space for margins
        rheight=7.5              !
        itype=1
      else if(csize(1:1).eq."P") then
        rheight=10.0             !leave space for margins
        rwidth =7.5              !
        itype=0
      else
       goto 500
      endif

      if(csize(2:2) .eq. "L") then !large font
        rlines_per_inch=6.0
        rchars_per_inch=10.0
        itype=itype+0
      else if(csize(2:2) .eq. "S") then ! small font
        rlines_per_inch=8.0
        rchars_per_inch=16.6
        itype=itype+2
      else
        goto 500
      endif
      maxwidth=int(rchars_per_inch*rwidth)
      maxline =int(rlines_per_inch*rheight)-1
      call setprint(ierr,itype)
      ierr=0
      if(maxwidth .gt. 135) maxwidth=135
      return


500   continue
      ierr=-1
      write(*,*) "Setup_printer: Unknown paper_size option: ",
     >   cpaper_size
      return
      end

