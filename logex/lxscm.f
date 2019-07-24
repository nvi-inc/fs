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
