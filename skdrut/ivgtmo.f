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
      integer FUNCTION ivgtmo(cdef,IKEY)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
C     CHECK THROUGH LIST OF mode def names FOR A MATCH WITH cdef.
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
      character*128 cdef
      integer fvex_len,i1,i2,ikey,i
      logical kmatch
      IKEY=0
      ivgtmo = 0
      IF (NCODES.LE.0) RETURN
      kmatch=.false.
      i=1
      DO while (i.le.NCODES.and..not.kmatch)
        i1=fvex_len(modedefnames(i))
        i2=fvex_len(cdef)
        kmatch= (modedefnames(I)(1:i1).eq.cdef(1:i2))
        i=i+1
      enddo
      i=i-1
      if (i.gt.ncodes) RETURN
      IKEY=I
      ivgtmo = I
      RETURN
      END
