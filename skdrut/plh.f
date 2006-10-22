      SUBROUTINE PLH(STAP,PHI,ELON,H)!KJC <830628.1111>,LAT
      IMPLICIT NONE
!
! 1.  PLH PROGRAM SPECIFICATION
!
! 1.1 Convert earth X,Y,Z coordinates to geoditic latitude,
!     east longitude and height above the ellipsoidal earth.
!
! 1.2 REFERENCES: Chopo Ma, "Introduction to Geodesy", Ewing & Mitchell,p. 93.
!
! 2.  PLH INTERFACE
!
! 2.1 Parameter File
!
! 2.2 INPUT Variables:
!
      REAL*8 STAP(3)
!
! STAP - Array holding X,Y,Z (meters)
!
! 2.3 OUTPUT Variables:
!
      REAL*8 PHI,ELON,H
!
! ELON - East longitude (radians)
! H - Height above the ellipsoidal earth (meters)
! PHI - Geoditic latitude (radians)
!
! 2.4 COMMON BLOCKS USED
!
! 2.5 SUBROUTINE INTERFACE
!
!     CALLING SUBROUTINES:
!       CALLED SUBROUTINES:
!
! 3.  LOCAL VARIABLES
!
      INTEGER*2 J
      REAL*8 DELTA,DTOR,ESQ1,ESQ,T,XYSQ,ZT,H1,SINPHI,ESQSP,H2,T1
      REAL*8 RTXYSQ,RAD,FM1,PI
!
      DATA PI /3.1415926535897932D0/, FM1 /.33528918690D-02/
!
!**** Value for radius of the earth changed 5/2/95 by MWH
!****   in order to agree with that used by CALC and DBCAL
!****   (from database header)
!      DATA  RAD /0.6378145D+07/
      DATA  RAD /0.63781363D+07/
      DATA DELTA /.00000001D0/
!
! DELTA - Criterion for convergence of iterative procedure
! DTOR - Conversion from degrees to radians
!
! 4.  HISTORY
!   WHO          WHEN   WHAT
! George Maeda  790610  Created
!
! 5.  PLH PROGRAM STRUCTURE
!
! CALCULATE CONSTANTS
!
      DTOR = PI/180.0D0
      ESQ1=(1.D0-FM1)**2
      ESQ=1.D0-ESQ1
      T=ESQ*STAP(3)
      XYSQ=STAP(1)**2 + STAP(2)**2
!
! ITERATIVE PROCEDURE FOR HEIGHT
!
      DO 10 J=1,50
      ZT=STAP(3) + T
      H1=DSQRT(XYSQ+ZT**2)
      SINPHI=ZT/H1
      ESQSP=ESQ*SINPHI
      H2=RAD/DSQRT(1.D0-ESQSP*SINPHI)
      T1=H2*ESQSP
      IF (DABS(T1-T) .LT. DELTA) GOTO 20
10    T=T1
!
!  HEIGHT
!
20    H = H1 - H2
!
!  GEODETIC LATITUDE
!
      RTXYSQ=DSQRT(XYSQ)
      PHI=DATAN2(ZT,RTXYSQ)
!
!  EAST LONGITUDE
!
      ELON=DATAN2(STAP(2),STAP(1))
      RETURN
      END
