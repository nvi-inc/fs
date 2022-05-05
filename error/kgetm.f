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
      logical function kgetm(lu,imbuf,jbuf,il,idcb,idcbs,pcof,mpar,
     +                      ipar,phi,imdl,it)
C
      character*(*) imbuf
      dimension pcof(mpar),ipar(mpar),it(6)
      integer*2 jbuf(il)
      dimension idcb(1)
      double precision pcof,phi
C
      call gmodl(lu,idcb,imbuf,pcof,mpar,ipar,phi,
     +           imdl,it,jbuf,il,ierr,idcbs)
      kgetm=ierr.ne.0
C
      return
      end
