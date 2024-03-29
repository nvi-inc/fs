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
	subroutine bbbuf(imode,icod,fr)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C     BBBUF creates buffers that hold the lines with bbsynth commands
C     This routine is called only for switched sequences
   
C INPUT:
        integer icod    ! frequency code index
	integer imode   ! group 1 or 2 of the switched frequencies
	real fr(14)   ! the frequencies to write, should be filled
C                       with appropriate frequencies for the mode

C COMMON
      include '../skdrincl/skparm.ftni' 
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'

C CALLED by: VLBAH

C HISTORY
! 2020-12-30 JMG Removed variables which were not used. 
C NRV 910524 created
C nrv 930407 implicit none

C LOCAL
      integer iline   ! counter for up to 3 lines with 5 freqs each
      integer iz   ! counts up to 5 freqs on a line
      integer ix,iy

      iline = 0
      iz = 0
      do ix=1,nchan(istn,icod)
        if(mod(iz,5) .eq. 0) then
          cbuf= ' bbsynth = '
	  iy = 11
        endif

	if (fr(ix).ne.0.0) then
	  call bbsyn(iy,ix,fr(ix))
	  iz=iz+1
	  if (mod(iz,5).eq.0) then ! line is full
	    iline = iline+1
            cbbcbuf(imode,iline)=cbuf(1:iy)
	    ibbclen(imode,iline) = iy
	    nbbcbuf(imode) = iline
	  else
            cbuf(iy:iy)=","
            iy=iy+1
	 end if
        end if
      end do
      return
      end

