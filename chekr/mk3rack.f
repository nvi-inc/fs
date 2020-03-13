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
      subroutine mk3rack(lmodna,lwho,icherr,ichecks,nverr,niferr,
     .                   nfmerr)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer*2 lmodna(1), lwho
      integer icherr(1), ichecks(1), nverr, niferr, nfmerr
C 
C  SUBROUTINES CALLED:
C 
C     MATCN - to get data from the modules
C     LOGIT - to log and display the error
C 
C  LOCAL VARIABLES: 
C 
      dimension ip(5)             ! - for RMPAR
      integer*2 ibuf1(40)
      dimension nbufs(17), icodes(4,17)
      integer rn_take
C      - MODule NAmes, 2-char codes
C      - Number of BUFfers for each module
C      - Integer CODES for MATCN for each buffer
C
C  INITIALIZED:
C
      data nbufs/15*2,2,2/
      data icodes/-1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0, -53,-4,0,0/
      data nmod/17/
C
      do iloop=1,nmod
        call fs_get_icheck(icheck(iloop),iloop)
        if(icheck(iloop).le.0.or.ichecks(iloop).ne.icheck(iloop)) then
           if(iloop.le.15) then
              tpivc(iloop)=65536
              call fs_set_tpivc(tpivc,iloop)
           else if(iloop.eq.16) then
              mifd_tpi(1)=65536
              call fs_set_mifd_tpi(mifd_tpi,1)
              mifd_tpi(2)=65536
              call fs_set_mifd_tpi(mifd_tpi,2)
           endif
           goto 699
        endif
        do jj=1,2
          ibuf1(2) = lmodna(iloop)
          iclass = 0
          do j=1,nbufs(iloop)
            ibuf1(1) = icodes(j,iloop)
            call put_buf(iclass,ibuf1,-4,'fs','  ')
          enddo
C
          ibuf1(1) = 8
          ibuf1(3) = o'47'   ! an apostrophe '
          call put_buf(iclass,ibuf1,-5,'fs','  ')
C Finally, get alarm status
         ierr=rn_take('fsctl',0)
          call run_matcn(iclass,nbufs(iloop)+1)
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
        call logit7(0,0,0,0,ierr,lwho,lmodna(iloop))
        if(iloop.le.15) then
           tpivc(iloop)=65536
           call fs_set_tpivc(tpivc,iloop)
        else if(iloop.eq.16) then
           mifd_tpi(1)=65536
           call fs_set_mifd_tpi(mifd_tpi,1)
           mifd_tpi(2)=65536
           call fs_set_mifd_tpi(mifd_tpi,2)
        endif
        goto 699
C There was an error in MATCN.  Log it and go on to the next module.
C
C 3. This is the VC section.
C
300     continue
C
        if (iloop.gt.15) goto 400
        call getvc(iclass,nverr,icherr,iloop)
        goto 699
C
C 4. This is the IF distributor section.
C
400     continue
C
        if (iloop.ne.16) goto 500
        call getif(iclass,nverr,niferr,icherr)
        goto 699
C
C
C 5. This is the Formatter section.
C
500     continue
C
        if (iloop.ne.17) goto 699
        call getfm(iclass,nverr,niferr,nfmerr,icherr)
        goto 699
C
C This is the end of the checking loop over modules. 
C 
c       call clrcl(iclass)
699     continue
      enddo
C
      return
      end
