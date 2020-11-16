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

! ******************************************************************************
      REAL*8 function tmjd(y_in,m_in,d,ut)
      implicit none
! Adapted from J. Boehm's matlab code.
!  V1.00   2009Jan16  JMGipson
!  2009Sep30 Modified to prserver y_in,m_in
      integer*2 y_in,m_in
      INTEGER*2 y,m,d    !year (4 digit), month, day
      REAL*8  ut       !fraction of a day.
! local
      REAL*8  JD
      REAL*8  b

      tmjd=0.d0
      y=y_in
      m=m_in
      if (m.le.2) THEN
         m = m+12
         y = y-1
      ENDIF
!  if date is before Oct 4, 1582
      IF( (y.le.1582).and. (m.le.10).and. (d.le.4)) then
         b = -2
      else
         b = int(y/400)-int(y/100)
      endif

! The line below was in the original code and is a bug.
!      jd = int(365.25*y)+int(30.6001*(m+1))+b+1720996.5+d+ut/24.d0
      jd = int(365.25*y)+int(30.6001*(m+1))+b+1720996.5+d+ut

      tmjd = jd-2400000.5
      return
      END
