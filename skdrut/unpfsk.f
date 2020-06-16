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
      SUBROUTINE unpfsk(IBUF,ILEN,IERR,lfr,lc,lst,ns)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     UNPFR unpacks the "F" lines in the $CODES section.
C
      include '../skdrincl/skparm.ftni'

C  900117 NRV Created, modeled after UNPFR of old FRCAT program
C  930225 nrv implicit none
C  950522 nrv Remove check for specific letters for valid modes.
C 951019 nrv Observing mode may be 8 characters
C            Change "14" to max_chan
C 951116 nrv Split into two routines, one to read the schedule
C            file line with station names, and the other to read
C            the catalog header line. This one reads the schedule.
C 951213 nrv For backward compatibility, do not blow up if the
C            sub-code and station names are missing!
C 960117 nrv For compatibility with PC-SCHED, do not blow up if
C            the fields after the code are different, just ignore.
C 960405 nrv Remove "lsub" from reading
! 2007May04 JMG  Used to bomb out if stations were numbers
!                Don't check for numeric form. This makes imcompatible with PC sked.
C
C  INPUT:
      integer*2 IBUF(*) ! buffer having the record
      integer ilen ! length of the record in IBUF, in words.
C
C  OUTPUT
      integer ierr ! 0=OK, -100-n=error reading nth field in the record
      integer*2 LFR(4)      ! name of frequency sequence
      integer*2 LC          ! frequency code - 2 characters
      integer*2 lst(4,max_stn) ! list of stations for this code
      integer ns ! number of station names found
C
C  LOCAL:
      integer ic1,ic2,nch,ich,idumy
      integer ichmv
C
C
      IERR = 0
      ICH=1
C
C Line format is:
C F SGPVLBSX   SX  WIDESX   GILCREEK  KOKEE ....
C   name      code sub-code station1  station2  ...
C PC-SCHED format is:
C F 86GHz      Ma  1 14 15 A 4.000 -  1 883411951

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
C     Initialize output variables in case we return early.

      ns=0

C     List of station names, 8 characters each
C
      ns=0
      do while (ic1.gt.0)
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        if (ic1.gt.0) then
          NCH = IC2-IC1+1
            IF  (NCH.GT.8) THEN
              IERR = -104-ns
              RETURN
            END IF
          ns=ns+1
          CALL IFILL(lst(1,ns),1,8,oblank)
          IDUMY = ICHMV(lst(1,ns),1,IBUF,IC1,NCH)
        endif
      enddo
C
      RETURN
      END
