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
      subroutine snap_check(BitDens,idirp)
! passed
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'
      double precision BitDens
      integer idirp

! local
      character ldir
      character*3 ltmp
      integer ntmp
      character lpost

      if(idirp .eq. 1) then
         ldir="f"
      else
         ldir="r"
      endif

      if(bitdens .lt. 40000.0) then
        ntmp=3
        ltmp="135"
      else
        ntmp=2
        ltmp="80"
      endif

      if(krec_append) then
        lpost=crec(irec)
      else
        lpost=" "
      endif
      write(lufile,'("check",a,a1,a1)') ltmp(1:ntmp),ldir,lpost

      return
      end
