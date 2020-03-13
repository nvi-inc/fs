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
      subroutine delete_comma_and_write(lu_out,ibuf,nch)
!
      integer lu_out
      integer ibuf(*)
      integer nch
      integer ierr
      integer oblank
      data oblank/32/    !ascii space

      nch=nch-1
      CALL IFILL(IBUF,NCH,1,oblank)

      call hol2lower(ibuf,(nch+1))
      CALL writf_asc(LU_OUT,IERR,IBUF,(NCH+1)/2)
      nch=0
      return
      end
