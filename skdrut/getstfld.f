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
      subroutine getstfld(stdef,stmt,prim,ivexnum,cout,nfields,
     .lu,ierr)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C     Get all the fields associated with one statement for
C     a station.

      include ../skdrincl/skparm.ftni

C History:
C 960516 nrv New.

C Input:
      integer lu ! for error messages
      character*(*) stdef
      character*(*) stmt ! statement to get
      character*(*) prim ! primitive section name
      integer ivexnum    ! vex file number

C Output:
      integer nfields
      character*(*) cout(max_fld)
      integer ierr

C Local:
      integer i,i1,i2,i3
      integer trimlen,fget_station_lowl,vex_field ! functions


C  1. Get the low level statement.

      ierr = fget_station_lowl(nfields,stdef,stmt,prim,ivexnum)

      i1=trimlen(stmt)
      i2=trimlen(prim)
      i3=trimlen(stdef)

      if (ierr.ne.0) then
        write(lu,9901) ierr,stmt(1:i1),prim(1:i2),stdef(1:i3)
9901    format('GETSTFLD01 - VEX error ',i6,' in ',a,' ',a,
     .  ' for station ',a)
        return
      endif

C  2. Now get the fields.

      do i=1,nfields
        ierr = vex_field(i,cout(i))
        if (ierr.ne.0) then
          write(lu,9902) ierr,i,stmt(1:i1),prim(1:i2),stdef(1:i3)
9902      format('GETSTFLD02 - Error ',i6,' getting field ',i5,
     .    ' in ',a,' ',a,' for station ',a)
          return
        endif
      enddo

      return
      end
