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
      integer function iptra(rain,lbuf,icnext)
C
      double precision ra,ra1,ra2,ra3,rain
      include '../include/dpi.i'
C
C RA
C
      ra=rain*rad2sec*10.0d0
      ih=int(ra/36000.0d0)
      ra1=ra-36000.0d0*float(ih)
      im=int(ra1/600.0d0)
      ra2=ra1-600.0d0*float(im)
      is=int(ra2/10.d0)
      ra3=ra2-10.0d0*float(is)
      its=int(ra3+0.5d0)
      if (its.lt.0) its=0
      if (its.gt.9) its=9
C
      iptra=icnext+ib2as(ih,lbuf,icnext,o'40000'+o'400'*2+2)
      iptra=iptra+ib2as(im,lbuf,iptra,o'40000'+o'400'*2+2)
      iptra=iptra+ib2as(is,lbuf,iptra,o'40000'+o'400'*2+2)
      iptra=ichmv_ch(lbuf,iptra,'.')
      iptra=iptra+ib2as(its,lbuf,iptra,o'40000'+o'400'*1+1)

      return
      end
