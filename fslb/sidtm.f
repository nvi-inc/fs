      subroutine sidtm(jd,sidtm0,fract) 
C
      include '../include/dpi.i'
C
      double precision sidtm0,fract,t 
C
C     M.E.ASH AND R.A.GOLDSTEIN  JULY 1964
C             JD = INPUT JULIAN DAY NUMBER AS COMPUTED BY "JULDA" 21MX
C                =  (JD-2440000)  
C     SIDTM0 = OUTPUT MEAM SIDEREAL TIME AT 0 HR UT 
C        = MEAN SIDEREAL TIME AT JULIAN DATE JD-.5 (IN RADIANS) 
C     FRACT = OUTPUT RATIO BETWEEN MEAN SIDEREAL TIME AND UNIVERSAL TIME 
C             MULTIPLIED BY TWOPI DIVIDED BY 86,400  
C
      t=jd
      t=t+24980.d0
      t=t-0.5d0 
      fract=7.292115855d-5+t*1.1727115d-19
      sidtm0=1.7399358947d0+t*(1.7202791266d-2+t*5.06409d-15) 
      j=sidtm0/DTWOPI
      if (sidtm0) 1,2,2
1     j=j-1 
2     t=j 
      sidtm0=sidtm0-t*DTWOPI 

      return
      end 
