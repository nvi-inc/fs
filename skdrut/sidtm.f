      SUBROUTINE sidtm(JD,SIDTM0,FRACT)
      implicit none
      real*8 SIDTM0,FRACT,T
      integer jd,j
      include "../skdrincl/constants.ftni"
C     M.E.ASH AND R.A.GOLDSTEIN  JULY 1964
C             JD = INPUT JULIAN DAY NUMBER AS COMPUTED BY "JULDA" 21MX
C                =  (JD-2440000)
C     SIDTM0 = OUTPUT MEAM SIDEREAL TIME AT 0 HR UT
C        = MEAN SIDEREAL TIME AT JULIAN DATE JD-.5 (IN RADIANS)
C     FRACT = OUTPUT RATIO BETWEEN MEAN SIDEREAL TIME AND UNIVERSAL TIME MUL
      T=JD
      T=T+24980.D0
      T=T-0.5D0
      FRACT=7.292115855D-5+T*1.1727115D-19
      SIDTM0=1.7399358947D0+T*(1.7202791266D-2+T*5.06409D-15)
      J=SIDTM0/(2.D0*PI)
      IF(SIDTM0) 1,2,2
1     J=J-1
2     T=J
      SIDTM0=SIDTM0-T*2.D0*PI
      RETURN
      END
