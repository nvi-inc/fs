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
      integer function durscan(ibuf,nch,idur)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include '../skdrincl/skparm.ftni'
C DURSCAN add the duration to the scan line
C NOTE: ibuf and nch are modified on return.
C History
C 970722 nrv New. Removed from addscan and newscan
C 001101 nrv Change max length of field to 5 characters, as allowed for
C            in newscan. Put 1 character space before the value.

C Input AND Output
      integer*2 ibuf(*)
      integer nch ! next blank character in ibuf
      integer idur ! duration in seconds
C Called by: NEWSCAN

C Local
      integer*2 ibufx(4)
      integer i,imaxlen
      integer ichmv,ib2as ! function

C     imaxlen=8 ! longest integer scan length (seconds)
      imaxlen=5 ! longest integer scan length (seconds)
      call ifill(ibufx,1,imaxlen,oblank)
C  Convert the integer into a temporary buffer because
C  ib2as can't handle array indices greater than 256.
      i = ib2as(idur,ibufx,1,z'8000'+imaxlen) ! put into temporary buffer
C  Now move the converted value into the buffer, left justified
      nch = ichmv(ibuf,nch+1,ibufx,1,i)
      durscan=nch

      return
      end
