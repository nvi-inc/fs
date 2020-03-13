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
      subroutine mk3drive(lwho,lmodna,nverr,niferr,nfmerr,ntperr,
     .                    icherr,ichecks,indxtp)
C
      include '../include/fscom.i'
C
C  INPUT PARAMETERS
C
      integer*2 lmodna(1), lwho
      integer nverr,niferr,nfmerr,ntperr,icherr(1)
      integer ichecks(1),indxtp
C
C LOCAL VARIABLES
C
      dimension ip(5)             ! - for RMPAR
      integer*2 ibuf1(40)
      integer icodes(4)
      integer rn_take
      data  icodes /-1,-2,-3,-4/

      call fs_get_drive(drive)
      call fs_get_icheck(icheck(18+indxtp-1),18+indxtp-1)
      if(icheck(18+indxtp-1).le.0.or.
     $     ichecks(18+indxtp-1).ne.icheck(18+indxtp-1)) goto 699
      do jj=1,2
        ibuf1(2) = lmodna(18+indxtp-1)
        iclass = 0
        do j=1,4
C  For the Mark IV tape drive, do not want to send ! strobe, which
C  is mode -1 to matcn. Replace with -5 which is the + strobe.
          if (MK4.eq.drive(indxtp).and.j.eq.1) then
            ibuf1(1) = -5
          else
            ibuf1(1) = icodes(j)
          endif
          call put_buf(iclass,ibuf1,-4,'fs','  ')
        enddo
C
        ibuf1(1) = 8
        ibuf1(3) = o'47'   ! an apostrophe '
        call put_buf(iclass,ibuf1,-5,'fs','  ')
C Finally, get alarm status
        ierr=rn_take('fsctl',0)
        call run_matcn(iclass,5)
        call rn_put('fsctl')
C Send our requests to MATCN for the data
        call rmpar(ip)
        iclass = ip(1)
        nrec = ip(2)
        ierr = ip(3)
C
        if (ierr.ge.0) goto 300
        call clrcl(iclass)
      enddo
      call logit7(0,0,0,0,ierr,lwho,lmodna(18+indxtp-1))
      goto 699
C
300   continue
C
      call gettp(iclass,nverr,niferr,nfmerr,ntperr,icherr,indxtp)
C
699   continue
      return
      end
