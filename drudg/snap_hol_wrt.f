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
      subroutine snap_hol_wrt(lu_outfile,lhol,nch)
! write out snap holerith command
      implicit none
!function
      integer  ichmv

!passed
      integer lu_outfile
      integer lhol(*)           !some holerith
      integer nch
      integer nch2
! local
      integer*2 ibuf2(50)
      character*100 cbuf2
      equivalence (cbuf2,ibuf2)
      integer iblen

      iblen=100
      cbuf2=" "
      if(nch .gt. 100) then
        write(*,*) "snap_hol_wrt:  trying to write too big a line!"
        write(*,*) "Max size, current size: ",100,nch
      endif
      nch2 = ICHMV(IBUF2,1,Lhol,1,nch)
      call c2lower(cbuf2(1:nch),cbuf2(1:nch))
      write(lu_outfile,'(a)') cbuf2(1:nch)

      return
      end
