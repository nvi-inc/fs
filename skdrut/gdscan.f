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
      integer function gdscan(ibuf,nch,igdata)

C GDSCAN add the "good data offset" to the scan line
C NOTE: ibuf and nch are modified on return.
C History
C 970722 nrv New. Removed from addscan and newscan

C Called by: NEWSCAN

C Input AND Output
      integer*2 ibuf(*)
      integer nch ! character to start with in ibuf
      integer igdata ! good data offset in seconds

C Local
      integer*2 ibufx(4)
      integer i
      integer ib2as ! function

C  Convert the integer into a temporary buffer because
C  ib2as can't handle array indices greater than 256.
      i = ib2as(igdata,ibufx,1,5) ! put into temporary buffer
C  Now move the converted value into the buffer
      nch = ichmv(ibuf,nch,ibufx,1,5)
      gdscan=nch

      return
      end
