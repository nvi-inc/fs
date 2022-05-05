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
      integer FUNCTION ivgtst(cdef,IKEY)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
C     CHECK THROUGH LIST OF station names FOR A MATCH WITH cdef.
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
! History
! 2000Nov09  NRV. Original version 
! 2014Jul07  JMGipson. Modified.  Previously version woudl return '1' if the station was not in the list.
!
      character*128 cdef
      integer fvex_len,i1,i2,ikey
    
      IKEY=0
      ivgtst = 0
      IF (NSTATN.LE.0) RETURN
       
      i2=fvex_len(cdef)
      do ikey=1,nstatn
        i1=fvex_len(stndefnames(ikey))  
        if(stndefnames(ikey)(1:i1).eq.cdef(1:i2)) goto 100                      
      enddo
      ikey=0

100   continue
      ivgtst=ikey
      return
    
      END
