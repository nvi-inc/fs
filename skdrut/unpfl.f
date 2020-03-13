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
      SUBROUTINE unpfl(IBUF,ILEN,IERR,LNAME,lb,cfl,nfl,fl)
C
C     unpfl unpacks a record containing flux information
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer containing the record
C     ILEN  - length of IBUF in words
C
C  OUTPUT:
      integer ierr,nfl
      integer*2 lb
C     IERR    - error return, 0=ok, -100-n=error in nth field
      integer*2 LNAME(max_sorlen/2) !source name on this line
C     lb - 1-character band designator
C     nfl - number of baseline/flux pairs or component number
      REAL*4 fl(max_flux)
C            - flux information, either flux/baseline pairs or
C              model components
      character*1 cfl ! type of entry, 'B' or 'M'
C
C  LOCAL:
      real*8 R,DAS2B
      integer ich,ic1,ic2,nc,nch,icsave,idumy
      integer ichmv,ifill ! function
C
C  INITIALIZED:
C
C  Modifications:
C  891113 NRV Created, copied from UNPVH
C  910924 NRV Add option for model components
C  930225 nrv implicit none
C 970114 nrv Change 4 to max_sorlen/2
C 000907 nrv Check NCH and IC1 before doing ICHMV.
C
C
C     Start the unpacking with the first character of the buffer.
C
      ICH = 1
C
C     The source name.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (ic1.eq.0.or.nch.le.0.or.NCH.gt.max_sorlen) THEN
        IERR = -101
        RETURN
      END IF  !
      IDUMY = ifill(LNAME,1,max_sorlen,oblank)
      IDUMY = ICHMV(LNAME,1,IBUF,ic1,nch)
C
C     The band ID.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (ic1.eq.0.or.nch.le.0.or.NCH.gt.1) THEN
        IERR = -102
        RETURN
      END IF  !
      call char2hol('  ',lb,1,2)
      IDUMY = ICHMV(lb,1,IBUF,IC1,nch)
C
C     Type of entry

      icsave = ich
      call gtfld(ibuf,ich,ilen*2,ic1,ic2)
      nch=ic2-ic1+1
C     if (nch.gt.1) then
C       ierr=-103
C       return
C     endif
      if (nch.eq.1) then
        call hol2char(ibuf,ic1,ic1,cfl)
      else
        cfl = ' '
      endif
      if (cfl.ne.'B'.and.cfl.ne.'M') then
C For backwards compatibility, assume this is an old-style
C flux entry. Force a 'B' type and re-read this field in
C the next section.
        cfl = 'B'
        ich = icsave
C       ierr=-103
C       return
      endif

C     Baseline/flux pairs OR model component parameters
C
      nfl = 0
      do while (ic1.gt.0)
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        IF (IC1.EQ.0) return
        NC = IC2-IC1+1
        R = DAS2B(IBUF,IC1,NC,IERR)
        IF (IERR.NE.0) THEN
          IERR = -103-nfl
          RETURN
        ENDIF
        nfl = nfl + 1
        fl(nfl) = R
      enddo
C
      RETURN
      END

