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
