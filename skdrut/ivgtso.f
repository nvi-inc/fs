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
      integer FUNCTION ivgtso(cdef,IKEY)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'
C     CHECK THROUGH LIST OF SOURCES FOR A MATCH WITH cdef
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
C 970114 nrv Change 4 to max_sorlen/2
      character*128 cdef
      integer*2 ldum(max_sorlen/2)
      integer il,ikey,i
      integer fvex_len
      LOGICAL KNAEQ,kmatch
      IKEY=0
      ivgtso = 0
      IF (NSOURC.LE.0) RETURN
      i=1
      kmatch=.false.
      do while (i.le.nsourc.and..not.kmatch)
        call ifill(ldum,1,max_sorlen,oblank)
        il = fvex_len(cdef) ! get name length
        call char2hol(cdef,ldum,1,il)
        kmatch=KNAEQ(ldum,LSORNA(1,I),max_sorlen/2)
        i=i+1
      enddo
      i=i-1
      if (i.gt.nsourc) return
      IKEY=I
      ivgtso = I
      RETURN
      END
