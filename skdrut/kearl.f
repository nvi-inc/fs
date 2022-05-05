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
C
      LOGICAL FUNCTION KEARL(ITIM1,ITIM2)!COMPARE TWO TIMES
C
C  KEARL compares two times and returns .TRUE. 
C  if the first is earlier than the second. 
C  Times are in the form yydddhhmmss (as found in schedule file).
C
C  HISTORY
C 900328 gag copied from drudg to use with ptobs
C 990427 nrv Totally rewritten for Y2K.
C
      implicit none
      integer*2 ITIM1(6),ITIM2(6)
      integer i1,i2,ias2b
      KEARL = .TRUE. ! t1 < t2
C Year
      i1 = ias2b(itim1,1,2)
      if (i1.ge.50) i1=i1+1900
      if (i1.lt.50) i1=i1+2000
      i2 = ias2b(itim2,1,2)
      if (i2.ge.50) i2=i2+1900
      if (i2.lt.50) i2=i2+2000
      if (i1.gt.i2) goto 999
      if (i1.lt.i2) return
C Day
      i1 = ias2b(itim1,3,3)
      i2 = ias2b(itim2,3,3)
      if (i1.gt.i2) goto 999
      if (i1.lt.i2) return
C Hour
      i1 = ias2b(itim1,6,2)
      i2 = ias2b(itim2,6,2)
      if (i1.gt.i2) goto 999
      if (i1.lt.i2) return
C Minute
      i1 = ias2b(itim1,8,2)
      i2 = ias2b(itim2,8,2)
      if (i1.gt.i2) goto 999
      if (i1.lt.i2) return
C Second
      i1 = ias2b(itim1,10,2)
      i2 = ias2b(itim2,10,2)
      if (i1.gt.i2) goto 999
      if (i1.lt.i2) return
C
C     DO 100 I=1,11
C       I1 = JCHAR(ITIM1,I)
C       I2 = JCHAR(ITIM2,I)
C       IF(I1.GT.I2)GOTO 200
C       IF(I1.LT.I2)GOTO 300
C100   CONTINUE
C200   kearl = .false.
C300   CONTINUE

999   KEARL = .FALSE.  ! t1 > t2
      RETURN
      END
