      SUBROUTINE GDATE (JD, YEAR,MONTH,DAY)
! Source:
! aa.usno.navy.mil/faq/docs/JD_formula.php
! Copied by JMGipson on 2019.06.06
!
!---COMPUTES THE GREGORIAN CALENDAR DATE (YEAR,MONTH,DAY)
!   GIVEN THE JULIAN DATE (JD).
!
      INTEGER JD,YEAR,MONTH,DAY,I,J,K
!
      L= JD+68569
      N= 4*L/146097
      L= L-(146097*N+3)/4
      I= 4000*(L+1)/1461001
      L= L-1461*I/4+31
      J= 80*L/2447
      K= L-2447*J/80
      L= J/11
      J= J+2-12*L
      I= 100*(N-49)+I+L

      YEAR= I
      MONTH= J
      DAY= K

      RETURN
      END
