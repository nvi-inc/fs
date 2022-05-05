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
      subroutine err_rep(lmodna,lwho,icherr,ichecks,nverr,niferr,nfmerr,
     .                   ntperr,indxtp)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer*2 lmodna(1), lwho
      integer icherr(1), ichecks(1), nverr, niferr, nfmerr, ntperr
C 
C  SUBROUTINES CALLED:
C 
C     LOGIT - to log and display the error
C 
C  LOCAL VARIABLES: 
C 
C  INITIALIZED:
C
      if(indxtp.eq.2) goto 780
      do iloop=1,15
        indx=(iloop-1)*nverr+1
        call fs_get_icheck(icheck(iloop),iloop)
        if(icheck(iloop).le.0.or.ichecks(iloop).ne.icheck(iloop))
     .     goto 720
        if(icherr(indx).ne.0) then
          call logit7(0,0,0,0,-301,lwho,lmodna(iloop))
          goto 720
        endif
        nerr=0
        do j=1,nverr-1
          if(icherr(indx+j).gt.0)nerr=nerr+1
        enddo
c        if(nerr.gt.nverr/2) then
c          call logit7(0,0,0,0,-310,lwho,lmodna(iloop))
c          goto 720
c        endif
        do j=1,nverr-1
          if(icherr(indx+j).gt.0)
     .      call logit7(0,0,0,0,-301-j,lwho,lmodna(iloop))
        enddo
720     continue
      enddo
C
C  IFD error reporting
C
      indx=15*nverr+1
      call fs_get_icheck(icheck(16),16)
      if(icheck(16).le.0.or.ichecks(16).ne.icheck(16)) goto 750
      if(icherr(indx).ne.0) then
        call logit7(0,0,0,0,-311,lwho,lmodna(16))
        goto 750
      endif
      nerr=0
      do j=1,niferr-1
        if(icherr(indx+j).gt.0) nerr=nerr+1
      enddo
c      if(nerr.gt.niferr/2) then
c        call logit7(0,0,0,0,-319,lwho,lmodna(16))
c        goto 750
c      endif
      do j=1,niferr-1
        if(icherr(indx+j).gt.0)
     .  call logit7(0,0,0,0,-311-j,lwho,lmodna(16))
      enddo
C
C  Formatter error reporting
C
750   continue
      indx=15*nverr+niferr+1
      call fs_get_icheck(icheck(17),17)
      if(icheck(17).le.0.or.ichecks(17).ne.icheck(17)) goto 780
      if(icherr(indx).ne.0) then
        call logit7(0,0,0,0,-320,lwho,lmodna(17))
        goto 780
      endif
      nerr=0
      do j=1,nfmerr-1
        if(icherr(indx+j).gt.0) nerr=nerr+1
      enddo
c      if(nerr.gt.nfmerr/2) then
c        call logit7(0,0,0,0,-331,lwho,lmodna(17))
c        goto 780
c      endif
      do j=1,nfmerr-1
        if (icherr(indx+j).gt.0)
     .  call logit7(0,0,0,0,-320-j,lwho,lmodna(17))
      enddo
C
C  Tape drive error reporting
C
780   continue
      indx=15*nverr+niferr+nfmerr+1
      call fs_get_icheck(icheck(18+indxtp-1),18+indxtp-1)
      if(icheck(18+indxtp-1).le.0.or.
     $     ichecks(18+indxtp-1).ne.icheck(18+indxtp-1)) goto 800
      if(icherr(indx).ne.0) then
        call logit7(0,0,0,0,-332,lwho,lmodna(18+indxtp-1))
        goto 800
      endif
      nerr=0
      do j=1,ntperr-1
        if(icherr(indx+j).gt.0) nerr=nerr+1
      enddo
c      if(nerr.gt.ntperr/2) then
c        call logit7(0,0,0,0,-347,lwho,lmodna(18+indxtp-1))
c        goto 800
c      endif
      do j=1,ntperr-1
        if(icherr(indx+j).gt.0)
     .  call logit7(0,0,0,0,-332-j,lwho,lmodna(18+indxtp-1))
      enddo
C
800   continue
      do j=1,169
        icherr(j)=0
      enddo
      return
      end
