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
