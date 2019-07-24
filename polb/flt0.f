      double precision function flt0(iwhich,x,y,p,ipar,phi)
C
C     COMPUTES THE FUNCTION AND DERIVATIVES FOR Y COORDINATE.
C     PARAMETER FOR IWHICH = 0
C     DERIVATIVE WITH RESPECT TO THE (IWHICH)th PARAMETER OTHERWISE
C
      dimension ipar(20)
      double precision f,x,y,cosx,cosy,sinx,siny,sinl,cosl,p(20),phi
      double precision cos2x,sin2x
C
      cosx=dcos(x)
      cosy=dcos(y)
      cos2x=dcos(2.0d0*x)
      sinx=dsin(x)
      siny=dsin(y)
      sin2x=dsin(2.d0*x)
      sinl=dsin(phi)
      cosl=dcos(phi)
      f=0.0d0
C
      if (iwhich.lt.0.or.iwhich.gt.20) goto 1000
      goto (1,1000,1000,1000,1000,  50,
     +           60,  70,  80,  90, 100,
     +          110,1000,1000,1000, 150,
     +          160,1000,1000,1000,1000) iwhich+1
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
1000  continue
      flt0=f

      return
      end
