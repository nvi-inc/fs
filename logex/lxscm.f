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
      subroutine lxscm(lsn,idayr,ihr,min,isc,idur,kmatch,khuh)
C
C LXSCM - Compares the LOG RUN-ID with the SCHEDULE RUN-ID for a match.
C
C MODIFICATIONS:
C
C    DATE     WHO  DESCRIPTION
C    820513   KNM  SUBROUTINE CREATED
C
C INPUT VARIABLES:
C
      integer*2 lsn(4)
C        - Contains the schedule source name
C
C     IDAYR - Schedule start day.
C     IHR - Schedule hour.
C     MIN - Schedule minutes.
C     ISC - Schedule start seconds.
C     IDUR- Schedule duration time.
C
C OUTPUT VARIABLES:
C
      logical kmatch
C       - A flag that indicates whether we have a matching schedule &
C         log observation.
C
      logical khuh
C      - true if the log entry is screwy
C
C COMMON BLOCKS USED:
C
      include 'lxcom.i'
C
C     CALLING SUBROUTINES:
C
C       LXSUM - SUMMARY command.
C
C LOCAL VARIABLES:
C
C
C *************************************************************
C
C 1. Compare the Log RUN-ID with the Schedule RUN-ID.
C
C *************************************************************
C
C
      kmatch = .false.
      khuh = .false.
      if(itl1.lt.itsk1.or.(itl1.eq.itsk1.and.itl2.lt.itsk2)) khuh=.true.
      if (.not.khuh) then
        if (ilrday.eq.idayr.and.ilrhrs.eq.ihr.and.ilrmin.eq.min)
     .  kmatch = .true.
        if (ilrday.lt.idayr.or.(idayr.eq.ilrday.and.ilrhrs.lt.ihr).or.
     .    (ilrday.eq.idayr.and.ilrhrs.eq.ihr.and.ilrmin.lt.min)
     .   ) khuh  =.true.
      end if
C
      return
      end
