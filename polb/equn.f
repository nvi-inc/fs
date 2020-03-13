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
