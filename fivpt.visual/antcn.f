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
      subroutine antcn(ip1,ierr)
C 
C ANTCN SCHEDULING SUBROUTINE 
C 
C INPUT:
C 
C       IP1 = THE FIRST PARAMETER IN THE RUN STRING 
C 
       include '../include/fscom.i'
C 
C OUTPUT: 
C 
C       IERR = 0 IF NO ERROR OCCURRED 
C 
      integer ip(5) 
      logical kbreak
C 
      data ntry/2/,idum/0/
C 
      itry=ntry 
15    continue
      if (kbreak('fivpt')) goto 80010
      call run_prog('antcn','wait',ip1,0,0,0,0)
      call rmpar(ip)
      if (ip(3).ge.0) return 
      call logit7ic(idum,idum,idum,-1,ip(3),ip(4),'fp')
      itry=itry-1 
      if (itry.gt.0) goto 15
      goto 80020 
C 
C BREAK DETECTED
C 
80010 continue
      ierr=-1
      return
C 
C FAILED COMMUNICATION
C 
80020 continue
      ierr=-30

      return
      end 
