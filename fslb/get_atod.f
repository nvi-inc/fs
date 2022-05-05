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
      subroutine get_atod(ichan,volt,ip,indxtp)

      integer ichan,indxtp
      integer*4 ip(5)
      real volt
C
C  GET_ATOD: get A/D sample
C
C     INPUT:
C       ICHAN: channel to sample (1-8, see AD2MA for details)
C
C     OUTPUT:
C       VOLT: sampled voltage
C       IP: field system parameter array
C
      include '../include/fscom.i'
C
      integer*2 ibuf(6)
      integer icount,itest,imove,ilvdt,nchar,iclass,nrec
      integer ilen
      data ilen/12/
C
C  check for and handle VLBA REC
C
      call fs_get_drive(drive)
      if(VLBA.eq.drive(indxtp).or.VLBA4.eq.drive(indxtp)) then
        call fc_get_vatod(ichan,volt,ip,indxtp)
        return
      endif
C
C onto M3
C
      nrec=0
      iclass=0
C
      ibuf(1)=0
      if(indxtp.eq.1) then
         call char2hol('h1',ibuf(2),1,2)
      else
         call char2hol('h2',ibuf(2),1,2)
      endif
      ilvdt=1
      call fs_get_klvdt_fs(klvdt_fs,indxtp)
      if(klvdt_fs(indxtp)) ilvdt=0
      call ad2ma(ibuf(3),ilvdt,0,ichan)
      call add_class(ibuf,-12,iclass,nrec)
C
      ibuf(1) = -2
      call add_class(ibuf,-12,iclass,nrec)
C
C   Now schedule MATCN
C
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      if(ip(3).ne.0) return
C
C  Get and decode voltage response from MATCN
C
      do i=1,ip(2)
        call get_class(ibuf,-ilen,ip,nchar)
      enddo
      call clrcl(ip(1))
      ip(2)=0
      call ma2ad(ibuf,imove,itest,icount)
      if(imove.ne.0) then
        ip(3)=-401
        call char2hol('q@',ip(4),1,2)
      endif
      volt=icount*4.8828125e-3
C
      return
      end
