*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      double precision function fln(iwhich,x,y,p,ipar,phi)
C
C     FITTING FUNCTION FOR X COORDINATE INCLUDING DERIVATIVES
C     FUNCTION FOR IWHICH = 0
C     DERIVATIVE WITH RESPECT TO THE (IWHICH)th PARAMETER OTHERWISE
C     COULD HANDLE UP TO 20 PARAMETERS
C
      dimension ipar(20)
      double precision f,cosx,cosy,cosl,sinx,siny,sinl,x,y,p(20),phi
      double precision sin2x,cos2x
C
      cosx=dcos(x)
      cosy=dcos(y)
      cosl=dcos(phi)
      sinx=dsin(x)
      siny=dsin(y)
      sinl=dsin(phi)
      sin2x=dsin(2.0d0*x)
      cos2x=dcos(2.0d0*x)
      f=0.0d0
C
      if (iwhich.lt.0.or.iwhich.gt.20) goto 1000
      goto (1,  10,  20,  30,  40,  50,
     +           60,1000,1000,1000,1000,
     +         1000, 120, 130, 140,1000,
     +         1000, 170, 180,1000,1000) iwhich+1
C
1     continue
      if (ipar( 1).ne.0) f=f+p(1)
      if (ipar( 2).ne.0) f=f-p(2)*cosl*sinx/cosy
      if (ipar( 3).ne.0) f=f+p(3)*siny/cosy
      if (ipar( 4).ne.0) f=f-p(4)/cosy
      if (ipar( 5).ne.0) f=f+p(5)*sinx*siny/cosy
      if (ipar( 6).ne.0) f=f-p(6)*siny*cosx/cosy
      if (ipar(12).ne.0) f=f+p(12)*x
      if (ipar(13).ne.0) f=f+p(13)*cosx
      if (ipar(14).ne.0) f=f+p(14)*sinx
      if (ipar(17).ne.0) f=f+p(17)*cos2x
      if (ipar(18).ne.0) f=f+p(18)*sin2x
      goto 1000
C
10    continue
      if (ipar(1).ne.0) f=1.0d0
      goto 1000
C
20    continue
      if (ipar(2).ne.0) f=-cosl*sinx/cosy
      goto 1000
C
30    continue
      if (ipar(3).ne.0) f= siny/cosy
      goto 1000
C
40    continue
      if (ipar(4).ne.0) f=-1.0d0/cosy
      goto 1000
C
50    continue
      if (ipar(5).ne.0) f= (sinx*siny)/cosy
      goto 1000
C
60    continue
      if (ipar(6).ne.0) f=-(cosx*siny)/cosy
      goto 1000
120   continue
      if (ipar(12).ne.0) f=x
      goto 1000
130   continue
      if (ipar(13).ne.0) f=cosx
      goto 1000
140   continue
      if (ipar(14).ne.0) f=sinx
      goto 1000
170   continue
      if (ipar(17).ne.0) f=cos2x
      goto 1000
180   continue
      if (ipar(18).ne.0) f=sin2x
      goto 1000
C
1000  continue
      fln=f

      return
      end
