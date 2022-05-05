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
      logical function kpout(lut,idcb,ibuf,nchars,iobuf,lst)
C
      integer*2 ibuf(1)
      integer idcb(2)
      integer lut,lst
      logical kwrit
      integer fmpwrite2
      character*(*) iobuf

C
      if (lst.gt.0) call po_put_i(ibuf,nchars)
C
      id = fmpwrite2(idcb,ierr,ibuf,nchars)
      kpout=kwrit(lut,ierr,iobuf)
C
      return
      end
