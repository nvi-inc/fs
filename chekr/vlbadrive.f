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
      subroutine vlbadrive(lwho,indxtp)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer*2 lwho
C 
C 
C  SUBROUTINES CALLED:
C 
C
C  LOCAL VARIABLES: 
      integer icherr(8)
C
C
C  INITIALIZED:
      do j=1,8
        icherr(j)=0
      enddo
      call fs_get_ichvlba(ichvlba(18+indxtp-1),18+indxtp-1)
      ichecks=ichvlba(18+indxtp-1)
      if(ichvlba(18+indxtp-1).le.0) goto 199
      ierr=0
      call recchk(icherr,ierr,indxtp,0)
      if (ierr.ne.0) then
         if(indxtp.eq.1) then
            call logit7ic(0,0,0,0,ierr,lwho,'r1')
         else
            call logit7ic(0,0,0,0,ierr,lwho,'r2')
         endif
      endif
      call fs_get_ichvlba(ichvlba(18+indxtp-1),18+indxtp-1)
      if(ichvlba(18+indxtp-1).le.0.or.
     $     ichecks.ne.ichvlba(18+indxtp-1)) goto 199
      do j=1,8
        if (icherr(j).ne.0) then
           if(indxtp.eq.1) then
              call logit7ic(0,0,0,0,-231-j,lwho,'r1')
           else
              call logit7ic(0,0,0,0,-231-j,lwho,'r2')
           endif
        endif
      enddo
199   continue
C
      return
      end
