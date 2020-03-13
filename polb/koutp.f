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
      logical function koutp(lu,idcb,idcbs,iapp,ipbuf)

      integer idcb(2)
      character*(*) ipbuf
C
      logical kexist
      integer IERR
      integer permissions
      integer ilen, trimlen
C
      inquire(file=ipbuf,exist=kexist)
      if (iapp.eq.1) then    ! Append
        call fmpopen(idcb,ipbuf,ierr,'a+',idum)
cxx      else if (iapp.eq.0) then  ! Overwrite
      else 
        call fmpopen(idcb,ipbuf,ierr,'w+',idum)
      endif
C
      if (ierr.eq.0) goto 2000
C
      koutp=.true.
      return
C
2000  continue
      if(.not.kexist) then
        permissions = o'0664'
        ilen=trimlen(ipbuf)
        call fc_chmod(ipbuf,permissions,ilen,ierr)
      endif
      koutp=.false.
c
      return
      end
