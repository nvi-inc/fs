C@SUNARC
      REAL*4 FUNCTION SUNARC(NSOR,mjd,ut) !Sun distance 
C
C   SUNARC calculates the distance of a source from the sun and
C             returns the arc distance in degrees.
C
      INCLUDE 'skparm.ftni'
C
C  INPUT VARIABLES:
      integer nsor,mjd
C    NSOR - source index
C    mjd - current date
      real*8 ut
C
C  OUTPUT VARIABLES:
C      SUNARC - arc distance of NSOR from sun, degrees
C          -1.0 if NSOR is a satellite
C
C  COMMON BLOCKS USED
      INCLUDE 'sourc.ftni'
C
C     CALLING SUBROUTINES: SKED, NEWOB, SOLIS, SKOPN
C     CALLED SUBROUTINES:  SUNPO
C
C  LOCAL VARIABLES
      real*8 rasun,decsun,cra,cd1,sd1,cd2,sd2,arg,arc
      real*4 arcd
C
C     DATE  WHO    CHANGES
C     890428 NRV Created, removed from NEWOB
C     900125 NRV Added call to SUNPO to calculate current sun position
C     930225 nrv implicit none
C
C
C     First get the current sun position
C
      call sunpo(mjd,ut,pi,rasun,decsun)
C
C     Compute distance of the source from the sun.
C
      IF  (NSOR.LE.NCELES) THEN  !"calculate distance from sun"
        CRA = DCOS(SORPDA(1,NSOR)-RASUN)
        CD1 = DCOS(DBLE(DECSUN))
        SD1 = DSIN(DBLE(DECSUN))
        CD2 = DCOS(SORPDA(2,NSOR))
        SD2 = DSIN(SORPDA(2,NSOR))
        ARG = CD1*CD2*CRA + SD1*SD2
        ARC = ATAN2(SQRT(1-ARG*ARG),ARG)
        ARCD = ARC*180./PI
      ELSE ! n/a for satellites
        ARCD = -1.0
      END IF  !"calculate distance from sun"
C
      SUNARC=ARCD
C
      RETURN
      END

