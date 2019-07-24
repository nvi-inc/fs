      real*4 function flxvl(imdl,arr,bm,corr)
      implicit none
      integer imdl
      real*4 arr(6),bm,corr
C
C   FLXVL CALCULATES APPARENT FLUX OF A SOURCE BASED ON A SIMPLE MODEL
C
C     SOURCE MODEL: IMDL = 1 = CONCENTRIC ELLIPTICAL GAUSSIAN, (two)
C                          2 = CIRCULAR DISK
C                          3 = TWO POINTS
C
C     FLUX AND COMPONENT SIZES: ARR
C
C                  MODEL
C            1       2     3
C  E  1    FLUX1   FLUX  TFLUX
C  L  2    MAJOR1  DIAM  SEPER
C  E  3    MINOR1    -     -
C  M  4    FLUX2     -     -
C  E  5    MAJOR2    -     -
C  N  6    MINOR2    -     -
C  T
C
C  FLXVL RETURNS THE APPARENT FLUX
C  CORR  RETURNS THE `EFFECT' CORRECTION OVER NO RESOLUTION
C
      if(imdl.eq.1) then
        flxvl=(arr(1)/sqrt((1.+(arr(2)/bm)**2)*(1.+(arr(3)/bm)**2)))
     &       +(arr(4)/sqrt((1.+(arr(5)/bm)**2)*(1.+(arr(6)/bm)**2)))
        corr=(arr(1)+arr(4))/flxvl
      else if(imdl.eq.2) then
       corr=(alog(2.)*(arr(2)/bm)**2)/(1.-exp(-alog(2.)*(arr(2)/bm)**2))
       flxvl=arr(1)/corr
      else if(imdl.eq.3) then
        corr=exp(4.*alog(2.)*((arr(2)/2.)/bm)**2)
        flxvl=arr(1)/corr
      else
        corr=1.0
        flxvl=0.0
      endif
C
      return
      end
