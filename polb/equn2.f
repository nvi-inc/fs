      subroutine equn2(it,eqofeq)
C
C     EQOFEQ IS RETURNED EQUATION OF EQUINOXES
C
      include '../include/dpi.i'
C
      double precision tjd,x,eqofeq
      integer it(6)
C
      TJD = JULDA(1,IT(5),IT(6)-1900) + 2440000.0D0 - 0.5d0
      TJD = TJD + (IT(1)*1d-2+it(2)+it(3)*6d1+it(4)*36d2)/86400d0
C
      CALL ETILT (TJD,X,X,EQOFEQ,X,X)
      EQOFEQ=EQOFEQ*DPI/43200.d0
C
      return
      end
