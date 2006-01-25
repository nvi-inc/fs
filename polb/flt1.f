      double precision function flt1(iwhich,x,y,p,ipar,phi)
C
C     COMPUTES THE FUNCTION AND DERIVATIVES FOR Y COORDINATE.
C     PARAMETER FOR IWHICH = 0
C     DERIVATIVE WITH RESPECT TO THE (IWHICH)th PARAMETER OTHERWISE
C
C     COULD HANDLE UP TO MAX_MODEL_PARAM PARAMETERS
C
      include '../include/params.i'
c
      integer ipar(MAX_MODEL_PARAM)
      double precision f,x,y,cosx,cosy,sinx,siny,sinl,cosl
      double precision p(MAX_MODEL_PARAM),phi
      double precision cos2x,sin2x,sin8y,cos8y
C
      cosx=dcos(x)
      cosy=dcos(y)
      cos2x=dcos(2.0d0*x)
      cos8y=dcos(8.0d0*y)
      sinx=dsin(x)
      siny=dsin(y)
      sin2x=dsin(2.d0*x)
      sin8y=dsin(8.0d0*y)
      sinl=dsin(phi)
      cosl=dcos(phi)
      f=0.0d0
C
      if (iwhich.lt.0.or.iwhich.gt.MAX_MODEL_PARAM) goto 1000
      goto (1,1000,1000,1000,1000,  50,
     +           60,  70,  80,  90, 100,
     +          110,1000,1000,1000, 150,
     +          160,1000,1000, 190, 200,
     +          210,220) iwhich+1
      goto 1000
C
1     continue
      if (ipar( 5).ne.0) f=f+p(5)*cosx
      if (ipar( 6).ne.0) f=f+p(6)*sinx
      if (ipar( 7).ne.0) f=f+p(7)
      if (ipar( 8).ne.0) f=f-p(8)*(cosl*siny*cosx-sinl*cosy)
      if (ipar( 9).ne.0) f=f+p(9)*y
      if (ipar(10).ne.0) f=f+p(10)*cosy
      if (ipar(11).ne.0) f=f+p(11)*siny
      if (ipar(15).ne.0) f=f+p(15)*cos2x
      if (ipar(16).ne.0) f=f+p(16)*sin2x
      if (ipar(19).ne.0) f=f+p(19)*cos8y
      if (ipar(20).ne.0) f=f+p(20)*sin8y
      if (ipar(21).ne.0) f=f+p(21)*cosx
      if (ipar(22).ne.0) f=f+p(22)*sinx
      goto 1000
C
50    continue
      if (ipar( 5).ne.0) f=cosx
      goto 1000
C
60    continue
      if (ipar( 6).ne.0) f=sinx
      goto 1000
C
70    continue
      if (ipar( 7).ne.0) f=1.0d0
      goto 1000
C
80    continue
      if (ipar( 8).ne.0) f=-(cosl*siny*cosx-sinl*cosy)
      goto 1000
C
90    continue
      if (ipar( 9).ne.0) f=y
      goto 1000
C
100   continue
      if (ipar(10).ne.0) f=cosy
      goto 1000
C
110   continue
      if (ipar(11).ne.0) f=siny
      goto 1000
C
150   continue
      if (ipar(15).ne.0) f=cos2x
      goto 1000
C
160   continue
      if (ipar(16).ne.0) f=sin2x
      goto 1000
C
190   continue
      if (ipar(19).ne.0) f=cos8y
      goto 1000
C
200   continue
      if (ipar(20).ne.0) f=sin8y
      goto 1000
C
210   continue
      if (ipar(21).ne.0) f=cosx
      goto 1000
C
220   continue
      if (ipar(22).ne.0) f=sinx
      goto 1000
C
1000  continue
      flt1=f

      return
      end
