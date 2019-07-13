      subroutine equn(nyrf,nday,eqofeq)
C
C   EQUATION OF EQUINOXES TO ABOUT 0.1 SECONDS OF TIME
C     FROME J.BALL'S MOVE
C
C     NYRF = YEAR SINCE 1900
C     NDAY = DAY OF YEAR
C     EQOFEQ IS RETURNED EQUATION OF EQUINOXES
C
      double precision t,al,a,aomega,arg,dlong,doblq,eqofeq
C
      al=nday
      a=nyrf
      t=(a+al/365.2421988d0)/100.d0
C
C     NUTATION
C
      aomega=259.183275d0-1934.142d0*t
      arg=aomega*0.0174532925d0
      dlong=-8.3597d-5*dsin(arg)
      doblq=4.4678d-5*dcos(arg)
      eqofeq=dlong*0.917450512d0

      return
      end
