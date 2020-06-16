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
      SUBROUTINE wrdur(ksw,istart,idur,iqual,ih,im,is,
     .  iz2,iz3,lu,isetup)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C  WRDUR writes the dur lines for the VLBA
C  pointing schedules.
C
C   HISTORY:
C     WHO   WHEN   WHAT
C     gag   900726 CREATED
C     nrv   910524 Added subscript to kswitch
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
C
C  INPUT:
        logical ksw
      integer ih,im,is,idur,iqual,lu
      integer iz2,iz3
        integer istart,isetup
C
C     CALLED BY: vlbat
C
C  LOCAL VARIABLES
      character*32 cdur
      integer iput,nch,idum,ierr
        integer ichmv_ch,ib2as ! functions
C
C  INITIALIZED:
      DATA cdur/'dur=00s qual=    stop=00h00m00s '/
C
C
      call ifill(ibuf,1,ibuf_len,oblank)

      if (idur.eq.0) then ! don't use dur= command
        nch=ichmv_ch(ibuf,1,'qual=')
        nch=nch+ib2as(iqual,ibuf,nch,iz3)
        nch=ichmv_ch(ibuf,nch,'  stop=')
        nch=nch+ib2as(ih,ibuf,nch,iz2)
        nch=ichmv_ch(ibuf,nch,'h')
        nch=nch+ib2as(im,ibuf,nch,iz2)
        nch=ichmv_ch(ibuf,nch,'m')
        nch=nch+ib2as(is,ibuf,nch,iz2)
        nch=ichmv_ch(ibuf,nch,'s  ')
        if (isetup.eq.0) nch=ichmv_ch(ibuf,nch,' !NEXT!  ')
        CALL writf_asc(LU,IERR,ibuf,(nch+1)/2)

C  Set dur=0 so that stop time is used
C  The stop time for the setup block is the start time of the scan

      else ! non-zero dur
      iput = 16
      if ((ksw).and.(isetup.eq.0)) then
        call char2hol('!BEGIN LOOP! ',ibuf,1,13)
        iput = 22
      else if ((.not.ksw).and.(isetup.eq.0)) then
        call char2hol(' !NEXT!',ibuf,33,40)
        iput = 20
      endif
      call char2hol(cdur,ibuf,istart,istart+31)
      idum = ib2as(idur,ibuf,istart+4,iz2)
      if (idur.eq.0) then
        call char2hol('  ',ibuf,istart+5,istart+6)
      else
        call char2hol('s',ibuf,istart+6,istart+6)
      end if
      Idum = ib2as(iqual,ibuf,istart+13,iz3)
      Idum = ib2as(ih,ibuf,istart+22,iz2)
      Idum = ib2as(im,ibuf,istart+25,iz2)
      Idum = ib2as(is,ibuf,istart+28,iz2)
      CALL writf_asc(LU,IERR,ibuf,iput)
      endif
      RETURN
      END

