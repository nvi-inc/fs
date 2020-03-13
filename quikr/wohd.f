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
      subroutine wohd(hd,fo,so,fi,si,ip,echo,lud,icl,indxtp)
      integer hd,ip(5),lud,icl
      real*4 fo(2),so(2),fi(2),si(2)
      logical echo
C
C  WOHD: Find Inchworm Speed
C
C  INPUT:
C     HD: Head to find speed of, 1 or 2
C     ICL: use old (=1) or new (=2) scale values or (=3) old
C     ECHO: debug echo control
C     LU: echo output lu
C
C  OUTPUT:
C     FO: fast out speed
C     SO: slow out speed
C     FI: fast in  speed
C     SI: slow in  speed
C     IP: Field System return parameters
C
      include '../include/fscom.i'
C
      integer ipass(2),ispdhd,idir
      real*4 tmove
      real*4 micnow(2),micold,volt(2)
      logical kauto
      data ipass/2*0/,kauto/.true./
C
C  get current location
C
      if(mod(icl,2).eq.1) then
        call mic_read(hd,ipass,kauto,micnow,ip,indxtp)
c                       !use existing calibration
      else
        call vlt_read(hd,volt,ip,indxtp)     ! raw measurements appropriate
        if(hd.eq.1) scale=rswrite_fs(indxtp) ! for new
        if(hd.eq.2) scale=rsread_fs(indxtp)
        micnow(hd)=volt(hd)*scale
      endif
      if(ip(3).ne.0) return
C
C FAST OUT CAL
C
      micold=micnow(hd)
      idir=1 !out
      ispdhd=1 !fast
      tmove=0.1 ! 0.1 second
      call head_move(hd,idir,ispdhd,tmove,ip,indxtp)
      if(ip(3).ne.0) return
C
      if(mod(icl,2).eq.1) then
        call mic_read(hd,ipass,kauto,micnow,ip,indxtp)
      else
        call vlt_read(hd,volt,ip,indxtp)
        micnow(hd)=volt(hd)*scale
      endif
      if(ip(3).ne.0) return
C
      fo(hd)=(1.0/tmove)*abs(micnow(hd)-micold)
      if(echo) write(lud,'(i3,3f8.1)') hd,fo(hd),micnow(hd),micold
C
C FAST IN
C
      micold=micnow(hd)
      idir=0 !in
      ispdhd=1 !fast
      tmove=0.1  ! 0.1 second
      call head_move(hd,idir,ispdhd,tmove,ip,indxtp)
      if(ip(3).ne.0) return
C
      if(mod(icl,2).eq.1) then
        call mic_read(hd,ipass,kauto,micnow,ip,indxtp)
      else
        call vlt_read(hd,volt,ip,indxtp)
        micnow(hd)=volt(hd)*scale
      endif
      if(ip(3).ne.0) return
C
      fi(hd)=(1.0/tmove)*abs(micnow(hd)-micold)
      if(echo) write(lud,'(i3,3f8.1)') hd,fi(hd),micnow(hd),micold
C
C SLOW OUT
C
      micold=micnow(hd)
      idir=1 !out
      ispdhd=0 !slow
      tmove=1.0 ! 1 second
      call head_move(hd,idir,ispdhd,tmove,ip,indxtp)
      if(ip(3).ne.0) return
C
      if(mod(icl,2).eq.1) then
        call mic_read(hd,ipass,kauto,micnow,ip,indxtp)
      else
        call vlt_read(hd,volt,ip,indxtp)
        micnow(hd)=volt(hd)*scale
      endif
      if(ip(3).ne.0) return
C
      so(hd)=(1.0/tmove)*abs(micnow(hd)-micold)
      if(echo) write(lud,'(i3,3f8.1)') hd,so(hd),micnow(hd),micold
C
C SLOW IN
C
      micold=micnow(hd)
      idir=0 !in
      ispdhd=0 !slow
      tmove=1.0 ! 1 second
      call head_move(hd,idir,ispdhd,tmove,ip,indxtp)
      if(ip(3).ne.0) return
C
      if(mod(icl,2).eq.1) then
        call mic_read(hd,ipass,kauto,micnow,ip,indxtp)
      else
        call vlt_read(hd,volt,ip,indxtp)
        micnow(hd)=volt(hd)*scale
      endif
      if(ip(3).ne.0) return
C
      si(hd)=(1.0/tmove)*abs(micnow(hd)-micold)
      if(echo) write(lud,'(i3,3f8.1)') hd,si(hd),micnow(hd),micold
C
      end
