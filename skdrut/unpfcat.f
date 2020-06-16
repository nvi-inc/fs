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
      SUBROUTINE unpfcat(IBUF,ILEN,IERR,
     .LFR,LC,lsub,lrx)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     UNPFR unpacks the lines in the FREQ.CAT catalog
C
      include '../skdrincl/skparm.ftni'

C  History:
C  900117 NRV Created, modeled after UNPFR of old FRCAT program
C  930225 nrv implicit none
C  950522 nrv Remove check for specific letters for valid modes.
C 951019 nrv Observing mode may be 8 characters
C            Change "14" to max_chan
C 951116 nrv Split into two routines, one to read the schedule
C            file line with station names, and the other to read
C            the catalog header line. This one reads the catalog.
C
C  INPUT:
      integer*2 IBUF(*) ! buffer having the record
      integer ilen ! length of the record in IBUF, in words.
C
C  OUTPUT
      integer ierr
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
      integer*2 LFR(4)      ! name of frequency record
      integer*2 LC          ! frequency code - 2 characters
      integer*2 lsub(4)      ! name of subgroup of frequencies
      integer*2 lrx(4)       ! receiver name
C
C  LOCAL:
      integer ic1,ic2,nch,ich,idumy
      integer ichmv
C
C
      IERR = 0
      ICH=1
C
C     Name - 8 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN
        IERR = -101
        RETURN
      END IF
      CALL IFILL(LFR,1,8,oblank)
      IDUMY = ICHMV(LFR,1,IBUF,IC1,NCH)
C
C     Frequency code, 2 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.2) THEN
        IERR = -102
        RETURN
      END IF
      call char2hol ('  ',LC,1,2)
      IDUMY = ICHMV(LC,1,IBUF,IC1,NCH)
C
C     sub group name, 8 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN
        IERR = -103
        RETURN
      END IF
      CALL IFILL(Lsub,1,8,oblank)
      IDUMY = ICHMV(Lsub,1,IBUF,IC1,NCH)
C
C     Observing mode, max 8 character
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      if (nch.gt.8) then
        ierr = -104
        return
      endif
      CALL IFILL(lrx,1,8,oblank)
      IDUMY = ICHMV(Lrx,1,ibuf,ic1,nch)
C
      RETURN
      END
