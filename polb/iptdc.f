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
      integer function iptdc(decin,lbuf,icnext)
C
      double precision dec,dec1,dec2,decin
      include '../include/dpi.i'
C
C DECLINATION
C
      dec=abs(decin)*rad2deg*3600.0d0
      ih=int(dec/3600.0d0)
      dec1=dec-3600.0d0*float(ih)
      im=int(dec1/60.0d0)
      dec2=dec1-60.0d0*float(im)
      is=int(dec2+0.5d0)
      if (is.lt.0) is=0
      if (is.gt.59) is=59
C
      iptdc=ichmv_ch(lbuf,icnext,'+')
      if (decin.lt.0.0) iptdc=ichmv_ch(lbuf,icnext,'-')
      iptdc=iptdc+ib2as(ih,lbuf,iptdc,o'40000'+o'400'*2+2)
      iptdc=iptdc+ib2as(im,lbuf,iptdc,o'40000'+o'400'*2+2)
      iptdc=iptdc+ib2as(is,lbuf,iptdc,o'40000'+o'400'*2+2)

      return
      end
