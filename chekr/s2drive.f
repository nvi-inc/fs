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
      subroutine s2drive(lwho,ichecks)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer*2 lwho
      integer ichecks(1)
C 
C 
C  SUBROUTINES CALLED:
C 
C
C  LOCAL VARIABLES: 
      integer icherr(18)
C
C
C  INITIALIZED:
      do j=1,18
        icherr(j)=0
      enddo
      call fs_get_ichs2(icheck(18))
      if(icheck(18).le.0.or.ichecks(18).ne.icheck(18)) return
      call s2recchk(icherr,lwho)

      call fs_get_ichs2(icheck(18))
      if(icheck(18).le.0.or.ichecks(18).ne.icheck(18)) return
      do j=1,18
        if (icherr(j).ne.0) then
          call logit7ic(0,0,0,0,-500-j,lwho,'r1')
        endif
      enddo
C
      return
      end
